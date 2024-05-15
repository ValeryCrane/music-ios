import Foundation
import AVFoundation

extension SampleRenderManager {
    private enum Constants {
        static let loopRenderingQueueSize = 3
    }
}

final class SampleRenderManager {

    var outputNode: AVAudioNode {
        speedUnit
    }

    private let sample: MutableSample
    private let metronome: Metronome

    private let sampleCachingManager = SampleCachingManager()
    private let audioEngineManager = AudioEngineManager()
    private let sampleBuffer: AVAudioPCMBuffer

    private let oddPlayerNode = AVAudioPlayerNode()
    private let evenPlayerNode = AVAudioPlayerNode()
    private let mixerNode = AVAudioMixerNode()
    private let speedUnit = AVAudioUnitVarispeed()

    private var isRendering = false
    private var lastRenderedLoop = -1
    private var renderingTaskTimer: Timer?

    init(sample: MutableSample, metronome: Metronome) async throws {
        self.sample = sample
        self.metronome = metronome
        sampleBuffer = try await .init(from: sampleCachingManager.loadSample(id: sample.sampleId))

        audioEngineManager.attachNode(speedUnit)
        audioEngineManager.attachNode(oddPlayerNode)
        audioEngineManager.attachNode(evenPlayerNode)
        audioEngineManager.attachNode(mixerNode)
        audioEngineManager.connect(oddPlayerNode, to: mixerNode)
        audioEngineManager.connect(evenPlayerNode, to: mixerNode)
        audioEngineManager.connect(mixerNode, to: speedUnit)

        metronome.addListener(self)
        updateSpeedUnitRate()
    }

    func startIfMetronomeIsPlaying() {
        if let beat = self.metronome.getBeat(ofHostTime: mach_absolute_time()) {
            startRenderingAt(beat: beat)
        }
    }

    private func updateSpeedUnitRate() {
        let sampleDuration = Double(sampleBuffer.frameLength) / sampleBuffer.format.sampleRate
        speedUnit.rate = Float(metronome.bpm / (Double(sample.beats) / (sampleDuration / 60.0)))
    }

    private func startRenderingAt(beat: Double) {
        isRendering = true
        let startLoop = beat / Double(sample.beats)
        lastRenderedLoop = Int(startLoop) - 1
        oddPlayerNode.play()
        evenPlayerNode.play()
        loopRenderingCycle()
    }

    private func stopRendering() {
        isRendering = false
        renderingTaskTimer?.invalidate()
        oddPlayerNode.stop()
        evenPlayerNode.stop()
    }

    private func render(loop: Int) {
        guard isRendering else { return }

        if let scheduleHostTime = metronome.getHostTime(ofBeat: Double(loop * sample.beats)) {
            let playerNode = loop % 2 == 0 ? evenPlayerNode : oddPlayerNode
            playerNode.scheduleBuffer(sampleBuffer, at: AVAudioTime(hostTime: scheduleHostTime), options: .interrupts)
        }

        lastRenderedLoop = max(lastRenderedLoop, loop)
    }

    private func loopRenderingCycle() {
        guard isRendering, let currentBeat = metronome.getBeat(ofHostTime: mach_absolute_time()) else { return }

        let currentLoop = Int(currentBeat / Double(sample.beats))
        let loopToRender = currentLoop + Constants.loopRenderingQueueSize
        if loopToRender > lastRenderedLoop {
            for loop in (lastRenderedLoop + 1) ... loopToRender {
                render(loop: loop)
            }
        }

        if let currentBeat = metronome.getBeat(ofHostTime: mach_absolute_time()) {
            let nextLoopStartBeat = sample.beats * (currentLoop + 1)
            let dispatchDelay = metronome.getDuration(ofBeats: Double(nextLoopStartBeat) - currentBeat)

            let timer = Timer(timeInterval: dispatchDelay, repeats: false) { [weak self] _ in
                self?.loopRenderingCycle()
            }
            RunLoop.main.add(timer, forMode: .common)
            renderingTaskTimer = timer
        }
    }
}

extension SampleRenderManager: MetronomeListener {
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
