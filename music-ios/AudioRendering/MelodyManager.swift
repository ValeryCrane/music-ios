import Foundation
import AVFoundation

// MARK: - MelodyManagerDelegate

protocol MelodyManagerDelegate: AnyObject {
    func melodyManager(_ melodyManager: MelodyManager, didDeleteNote note: MutableNote)
}

extension MelodyManager {
    private enum Constants {
        static let loopRenderingQueueSize = 2
    }
}

// MARK: - MelodyManager

final class MelodyManager {
    weak var delegate: MelodyManagerDelegate?

    // MARK: Public properties

    var outputNode: AVAudioNode {
        mainNode
    }

    var keyboardSize: Int {
        keyboard.keys.count
    }
    
    var measures: Int {
        melody.measures
    }

    var isPedalActive: Bool {
        melody.isPedalActive
    }

    var isMuted: Bool {
        melody.isMuted
    }

    var keyboardMiniature: KeyboardMiniature {
        .init(id: keyboard.id, name: keyboard.name, numberOfKeys: keyboard.keys.count)
    }

    // MARK: Private properties

    private let audioEngineManager = AudioEngineManager()
    private let keyboardCachingManager = KeyboardCachingManager()

    private let melody: MutableMelody
    private var keyboard: KeyboardCachingManager.Keyboard

    private let mainNode = AVAudioMixerNode()
    private var nodeMapping = ObjectMapper<MutableNote, AVAudioPlayerNode>()
    private var buffers: [AVAudioPCMBuffer]
    private var metronome: Metronome

    private var volume: Float = 1

    private var lastRenderedLoop: Int = -1
    private var isRendering: Bool = false
    private var renderingTaskTimer: Timer?

    // MARK: Init

    init(melody: MutableMelody, metronome: Metronome) async throws {
        self.melody = melody
        self.metronome = metronome
        self.keyboard = try await keyboardCachingManager.loadKeyboard(id: melody.keyboardId)
        self.buffers = try keyboard.keys.map { try .init(from: $0) }

        audioEngineManager.attachNode(mainNode)
        metronome.addListener(self)
    }

    // MARK: Setters

    func setVolume(_ volume: Float) {
        self.volume = volume
        if !melody.isMuted {
            mainNode.outputVolume = volume
        }
    }

    func setMuteState(isMuted: Bool) {
        melody.isMuted = isMuted
        if isMuted {
            mainNode.outputVolume = 0
        } else {
            mainNode.outputVolume = volume
        }
    }

    func setKeyboard(keyboardId: Int) async throws {
        guard melody.keyboardId != keyboardId else { return }

        stopRendering()
        melody.notes.forEach { nodeMapping[$0]?.stop() }

        let previousKeyboardSize = keyboard.keys.count
        keyboard = try await keyboardCachingManager.loadKeyboard(id: keyboardId)
        buffers = try keyboard.keys.map { try .init(from: $0) }
        melody.keyboardId = keyboardId

        if previousKeyboardSize != keyboard.keys.count {
            metronome.reset()
            for i in Array(0 ..< melody.notes.count).reversed() {
                if let node = nodeMapping[melody.notes[i]] {
                    audioEngineManager.detachNode(node)
                    nodeMapping[melody.notes[i]] = nil
                }
                delegate?.melodyManager(self, didDeleteNote: melody.notes.removeLast())
            }
        } else if metronome.isPlaying, let beat = metronome.getBeat(ofHostTime: mach_absolute_time()) {
            startRenderingAt(beat: beat)
        }
    }

    func setMeasures(_ measures: Int) {
        guard melody.measures != measures else { return }

        stopRendering()
        melody.measures = measures

        let totalBeats = Double(melody.measures * .beatsInMeasure)
        for i in Array(0 ..< melody.notes.count).reversed() {
            if melody.notes[i].end - .eps > totalBeats, let node = nodeMapping[melody.notes[i]] {
                audioEngineManager.detachNode(node)
                nodeMapping[melody.notes[i]] = nil
                delegate?.melodyManager(self, didDeleteNote: melody.notes.remove(at: i))
            }
        }
        
        if let beat = self.metronome.getBeat(ofHostTime: mach_absolute_time()) {
            startRenderingAt(beat: beat)
        }
    }

    func setPedalState(_ isActive: Bool) {
        guard melody.isPedalActive != isActive else { return }

        stopRendering()
        melody.isPedalActive = isActive
        if let beat = self.metronome.getBeat(ofHostTime: mach_absolute_time()) {
            startRenderingAt(beat: beat)
        }
    }

    func setMetronome(_ metronome: Metronome) {
        stopRendering()
        self.metronome.removeListener(self)
        self.metronome = metronome
        self.metronome.addListener(self)
        if self.metronome.isPlaying, let beat = self.metronome.getBeat(ofHostTime: mach_absolute_time()) {
            startRenderingAt(beat: beat)
        }
    }

    func willDeleteNotesSettingMeasures(_ measures: Int) -> Bool {
        let totalBeats = Double(measures * .beatsInMeasure)

        for i in Array(0 ..< melody.notes.count).reversed() {
            if melody.notes[i].end - .eps > totalBeats {
                return true
            }
        }

        return false
    }

    // MARK: Note modifiers

    func addNote(_ note: MutableNote) {
        melody.notes.append(note)

        let node = AVAudioPlayerNode()
        audioEngineManager.attachNode(node)
        audioEngineManager.connect(node, to: mainNode, format: buffers[note.keyNumber].format)
        nodeMapping[note] = node
        renderMissedLoops(ofNote: note)

        for i in Array(0 ..< melody.notes.count).reversed() {
            if areNotesIntersected(note, melody.notes[i]), let node = nodeMapping[melody.notes[i]] {
                audioEngineManager.detachNode(node)
                nodeMapping[melody.notes[i]] = nil
                delegate?.melodyManager(self, didDeleteNote: melody.notes.remove(at: i))
            }
        }
    }
    
    func deleteNote(_ note: MutableNote) {
        if let node = nodeMapping[note] {
            node.stop()
            audioEngineManager.detachNode(node)
        }

        nodeMapping[note] = nil
        melody.notes.removeAll(where: { $0 === note })
    }

    // MARK: Rendering

    private func startRenderingAt(beat: Double) {
        isRendering = true
        let startLoop = beat / Double(measures * .beatsInMeasure)
        lastRenderedLoop = Int(startLoop) - 1
        melody.notes.forEach { nodeMapping[$0]?.play() }
        loopRenderingCycle()
    }

    private func stopRendering() {
        isRendering = false
        renderingTaskTimer?.invalidate()
        melody.notes.forEach { nodeMapping[$0]?.stop() }
    }

    private func renderMissedLoops(ofNote note: MutableNote) {
        guard isRendering, let currentBeat = metronome.getBeat(ofHostTime: mach_absolute_time()) else { return }

        let currentLoop = Int(currentBeat / Double(measures * .beatsInMeasure))
        if let node = nodeMapping[note], currentLoop <= lastRenderedLoop {
            for loop in currentLoop ... lastRenderedLoop {
                render(note: note, atLoop: loop)
            }

            node.play()
        }
    }

    private func render(note: MutableNote, atLoop loop: Int) {
        let noteBeat = Double(measures * loop * .beatsInMeasure) + note.start
        if let node = nodeMapping[note], let scheduleHostTime = metronome.getHostTime(ofBeat: noteBeat) {
            if !melody.isPedalActive {
                let noteDuration = metronome.getDuration(ofBeats: note.end - note.start)
                let sampleRate = buffers[note.keyNumber].format.sampleRate
                buffers[note.keyNumber].frameLength = AVAudioFrameCount(sampleRate * noteDuration)
            }

            node.scheduleBuffer(
                buffers[note.keyNumber],
                at: .init(hostTime: scheduleHostTime),
                options: .interrupts,
                completionHandler: { [weak self] in
                    if let self = self {
                        buffers[note.keyNumber].frameLength = buffers[note.keyNumber].frameCapacity
                    }
                }
            )
        }
    }

    private func render(loop: Int) {
        guard isRendering else { return }

        for note in melody.notes {
            render(note: note, atLoop: loop)
        }

        lastRenderedLoop = max(lastRenderedLoop, loop)
    }

    private func loopRenderingCycle() {
        guard isRendering, let currentBeat = metronome.getBeat(ofHostTime: mach_absolute_time()) else { return }

        let currentLoop = Int(currentBeat / Double(measures * .beatsInMeasure))
        let loopToRender = currentLoop + Constants.loopRenderingQueueSize
        if loopToRender > lastRenderedLoop {
            for loop in (lastRenderedLoop + 1) ... loopToRender {
                render(loop: loop)
            }
        }

        if let currentBeat = metronome.getBeat(ofHostTime: mach_absolute_time()) {
            let nextLoopStartBeat = measures * .beatsInMeasure * (currentLoop + 1)
            let dispatchDelay = metronome.getDuration(ofBeats: Double(nextLoopStartBeat) - currentBeat)

            let timer = Timer(timeInterval: dispatchDelay, repeats: false) { [weak self] _ in
                self?.loopRenderingCycle()
            }
            RunLoop.main.add(timer, forMode: .common)
            renderingTaskTimer = timer
        }
    }

    // MARK: Private functions

    private func areNotesIntersected(_ lhs: MutableNote, _ rhs: MutableNote) -> Bool {
        if lhs.keyNumber != rhs.keyNumber {
            return false
        }

        let isLHSStartInsideRHS = lhs.start - .eps > rhs.start && lhs.start + .eps < rhs.end
        let isLHSEndInsideRHS = lhs.end - .eps > rhs.start && lhs.end + .eps < rhs.end
        let isRHSStartInsideLHS = rhs.start - .eps > lhs.start && rhs.start + .eps < lhs.end
        let isRHSEndInsideLHS = rhs.end - .eps > lhs.start && rhs.end + .eps < lhs.end

        return isLHSStartInsideRHS || isLHSEndInsideRHS || isRHSStartInsideLHS || isRHSEndInsideLHS
    }
}

// MARK: - MetronomeListener

extension MelodyManager: MetronomeListener {
    func metronome(_ metronome: Metronome, didStartPlayingAtBeat beat: Double) {
        startRenderingAt(beat: beat)
    }
    
    func metronome(_ metronome: Metronome, didStopPlayingAtBeat beat: Double) {
        stopRendering()
    }
    
    func metronome(_ metronome: Metronome, didUpdateBPM bpm: Double) {
        // TODO.
    }
}
