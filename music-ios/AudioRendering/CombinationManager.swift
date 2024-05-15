import Foundation
import AVFoundation

protocol CombinationManagerRenderDelegate: AnyObject {
    func combinationManagerDidChangeComposition(_ combinationManager: CombinationManager)
    func combinationManager(_ combinationManager: CombinationManager, shouldUpdateMuteState isMuted: Bool)
    func combinationManager(_ combinationManager: CombinationManager, shouldChangeOverallVolume volume: Float)
}

final class CombinationManager {
    weak var renderDelegate: CombinationManagerRenderDelegate?

    var outputNode: AVAudioNode {
        mainNode
    }

    private(set) var melodyManagers: [MelodyManager] = []
    private(set) var melodyEffectsManagers: [EffectsManager] = []
    private(set) var sampleManagers: [SampleRenderManager] = []
    private(set) var sampleEffectsManagers: [EffectsManager] = []
    private var melodyMuteMixerNodes: [AVAudioMixerNode] = []
    private var sampleMuteMixerNodes: [AVAudioMixerNode] = []

    private let metronome: Metronome
    private let combination: MutableCombination

    private let mainNode: AVAudioMixerNode
    private let serviceNode = AVAudioPlayerNode()
    private let audioEngineManager = AudioEngineManager()

    init(combination: MutableCombination, metronome: Metronome) async throws {
        self.combination = combination
        self.metronome = metronome

        let melodyManagers = try await withThrowingTaskGroup(of: (Int, MelodyManager).self) { group in
            var keyMap = [Int: MelodyManager]()

            combination.melodies.enumerated().forEach { (index, melody) in
                group.addTask {
                    return (index, try await MelodyManager(melody: melody, metronome: metronome))
                }
            }

            for try await melodyManagerInfo in group {
                keyMap[melodyManagerInfo.0] = melodyManagerInfo.1
            }

            return (0 ..< combination.melodies.count).compactMap { keyMap[$0] }
        }

        let sampleManagers = try await withThrowingTaskGroup(of: (Int, SampleRenderManager).self) { group in
            var keyMap = [Int: SampleRenderManager]()

            combination.samples.enumerated().forEach { (index, sample) in
                group.addTask {
                    return (index, try await SampleRenderManager(sample: sample, metronome: metronome))
                }
            }

            for try await sampleManagerInfo in group {
                keyMap[sampleManagerInfo.0] = sampleManagerInfo.1
            }

            return (0 ..< combination.samples.count).compactMap { keyMap[$0] }
        }

        mainNode = AVAudioMixerNode()
        audioEngineManager.attachNode(mainNode)
        audioEngineManager.attachNode(serviceNode)
        audioEngineManager.connect(serviceNode, to: mainNode)

        for i in 0 ..< combination.melodies.count {
            createNodesForMelodyManager(melodyManagers[i], melody: combination.melodies[i])
        }

        for i in 0 ..< combination.samples.count {
            createNodesForSampleManager(sampleManagers[i], sample: combination.samples[i])
        }
    }

    deinit {
        melodyMuteMixerNodes.forEach { audioEngineManager.detachNode($0) }
        sampleMuteMixerNodes.forEach { audioEngineManager.detachNode($0) }
        audioEngineManager.detachNode(serviceNode)
        audioEngineManager.detachNode(mainNode)
    }

    func startIfMetronomeIsPlaying() {
        melodyManagers.forEach { $0.startIfMetronomeIsPlaying() }
    }

    func getMuteState() -> Bool {
        combination.isMuted
    }

    func getMelodyNames() -> [String] {
        combination.melodies.map(\.name)
    }

    func getMelodyMuteStates() -> [Bool] {
        combination.melodies.map(\.isMuted)
    }

    func getSampleNames() -> [String] {
        combination.samples.map(\.name)
    }

    func getSampleMuteStates() -> [Bool] {
        combination.samples.map(\.isMuted)
    }

    func getBPM() -> Double {
        metronome.bpm
    }

    func setMuteState(isMuted: Bool) {
        renderDelegate?.combinationManager(self, shouldUpdateMuteState: isMuted)
    }

    func setMuteState(forMelodyAtIndex index: Int, isMuted: Bool) {
        melodyMuteMixerNodes[index].outputVolume = isMuted ? 0 : 1
        combination.melodies[index].isMuted = isMuted
    }

    func setMuteState(forSampleAtIndex index: Int, isMuted: Bool) {
        sampleMuteMixerNodes[index].outputVolume = isMuted ? 0 : 1
        combination.samples[index].isMuted = isMuted
    }

    func setOverallVolume(_ volume: Float) {
        renderDelegate?.combinationManager(self, shouldChangeOverallVolume: volume)
    }

    func addMelody(_ melody: MutableMelody) async throws {
        combination.melodies.append(melody)
        renderDelegate?.combinationManagerDidChangeComposition(self)

        let melodyManager = try await MelodyManager(melody: melody, metronome: metronome)
        createNodesForMelodyManager(melodyManager, melody: melody)
        melodyManager.startIfMetronomeIsPlaying()
    }

    func addSample(_ sample: MutableSample) async throws {
        combination.samples.append(sample)
        renderDelegate?.combinationManagerDidChangeComposition(self)

        let sampleManager = try await SampleRenderManager(sample: sample, metronome: metronome)
        createNodesForSampleManager(sampleManager, sample: sample)
        sampleManager.startIfMetronomeIsPlaying()
    }

    func prepareMelodyForEditing(atIndex index: Int, withMetronome internalMetronome: Metronome) {
        metronome.pause()
        melodyManagers[index].setMetronome(internalMetronome)
        audioEngineManager.disconnect(melodyEffectsManagers[index].outputNode)
        audioEngineManager.addNodeToMainMixer(melodyEffectsManagers[index].outputNode)
    }

    func restoreMelodyFromEditing(atIndex index: Int) {
        melodyManagers[index].setMetronome(metronome)
        audioEngineManager.disconnect(melodyEffectsManagers[index].outputNode)
        audioEngineManager.connect(melodyEffectsManagers[index].outputNode, to: melodyMuteMixerNodes[index])
    }

    private func createNodesForMelodyManager(_ melodyManager: MelodyManager, melody: MutableMelody) {
        let muteMixerNode = AVAudioMixerNode()
        let effectsManager = EffectsManager(effects: melody.effects)

        audioEngineManager.attachNode(muteMixerNode)
        audioEngineManager.connect(melodyManager.outputNode, to: effectsManager.inputNode)
        audioEngineManager.connect(effectsManager.outputNode, to: muteMixerNode)
        audioEngineManager.connect(muteMixerNode, to: mainNode)

        muteMixerNode.outputVolume = melody.isMuted ? 0 : 1
        effectsManager.renderDelegate = self
        melodyManager.renderDelegate = self

        melodyMuteMixerNodes.append(muteMixerNode)
        melodyEffectsManagers.append(effectsManager)
        melodyManagers.append(melodyManager)
    }

    private func createNodesForSampleManager(_ sampleManager: SampleRenderManager, sample: MutableSample) {
        let muteMixerNode = AVAudioMixerNode()
        let effectsManager = EffectsManager(effects: sample.effects)

        audioEngineManager.attachNode(muteMixerNode)
        audioEngineManager.connect(sampleManager.outputNode, to: effectsManager.inputNode)
        audioEngineManager.connect(effectsManager.outputNode, to: muteMixerNode)
        audioEngineManager.connect(muteMixerNode, to: mainNode)

        muteMixerNode.outputVolume = sample.isMuted ? 0 : 1
        effectsManager.renderDelegate = self

        sampleMuteMixerNodes.append(muteMixerNode)
        sampleEffectsManagers.append(effectsManager)
        sampleManagers.append(sampleManager)
    }
}

extension CombinationManager: MelodyManagerRenderDelegate {
    func melodyManagerDidChangeComposition(_ melodyManager: MelodyManager) {
        renderDelegate?.combinationManagerDidChangeComposition(self)
    }
}

extension CombinationManager: EffectsManagerRenderDelegate {
    func effectsManagerDidUpdateComposition(_ effectsManager: EffectsManager) {
        renderDelegate?.combinationManagerDidChangeComposition(self)
    }
}
