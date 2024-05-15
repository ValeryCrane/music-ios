import Foundation
import AVFoundation

protocol CompositionRenderManagerDelegate: AnyObject {
    func compositionRenderManagerDidChangeComposition(_ compositionRenderManager: CompositionRenderManager)
    func compositionRenderManagerDidUpdateCombinationMuteStates(_ compositionRenderManager: CompositionRenderManager)
}

// TODO: разобраться с неймингами.
final class CompositionRenderManager {
    weak var delegate: CompositionRenderManagerDelegate?

    var compositionId: Int {
        composition.id
    }

    private(set) var effectsManagers: [EffectsManager] = []
    private(set) var combinationManagers: [CombinationManager] = []
    private var muteMixerNodes: [AVAudioMixerNode] = []

    private let metronome: Metronome
    private let composition: MutableComposition

    private let mainNode: AVAudioMixerNode
    private let serviceNode = AVAudioPlayerNode()
    private let audioEngineManager = AudioEngineManager()

    private var currentPlayingCombinationIndex: Int?

    init(composition: MutableComposition) async throws {
        self.composition = composition
        let metronome = Metronome(bpm: Double(composition.bpm))

        let combinationManagers = try await withThrowingTaskGroup(of: (Int, CombinationManager).self) { group in
            var keyMap = [Int: CombinationManager]()

            composition.combinations.enumerated().forEach { (index, combination) in
                group.addTask {
                    return (index, try await CombinationManager(combination: combination, metronome: metronome))
                }
            }

            for try await combinationManagerInfo in group {
                keyMap[combinationManagerInfo.0] = combinationManagerInfo.1
            }

            return (0 ..< composition.combinations.count).compactMap { keyMap[$0] }
        }

        mainNode = AVAudioMixerNode()
        audioEngineManager.attachNode(mainNode)
        audioEngineManager.attachNode(serviceNode)
        audioEngineManager.connect(serviceNode, to: mainNode)

        self.metronome = metronome

        for i in 0 ..< composition.combinations.count {
            createNodesForCombinationManager(combinationManagers[i], combination: composition.combinations[i])
        }

        audioEngineManager.addNodeToMainMixer(mainNode)
    }

    deinit {
        muteMixerNodes.forEach { audioEngineManager.detachNode($0) }
        audioEngineManager.detachNode(serviceNode)
        audioEngineManager.detachNode(mainNode)
    }

    func getComposition() -> Composition {
        .init(composition)
    }

    func getCombinationNames() -> [String] {
        composition.combinations.map(\.name)
    }

    func getCombinationMuteStates() -> [Bool] {
        composition.combinations.map(\.isMuted)
    }

    func getBPM() -> Double {
        metronome.bpm
    }

    func setBPM(_ bpm: Double) {
        metronome.updateBPM(bpm)
        composition.bpm = Int(bpm + .eps)
        delegate?.compositionRenderManagerDidChangeComposition(self)
    }

    func addCombination(_ combination: MutableCombination) async throws {
        composition.combinations.append(combination)

        let combinationManager = try await CombinationManager(combination: combination, metronome: metronome)
        createNodesForCombinationManager(combinationManager, combination: combination)
        combinationManager.startIfMetronomeIsPlaying()

        delegate?.compositionRenderManagerDidChangeComposition(self)
    }

    func playCombination(atIndex index: Int) {
        if let currentPlayingCombinationIndex = currentPlayingCombinationIndex, currentPlayingCombinationIndex != index {
            composition.combinations[currentPlayingCombinationIndex].isMuted = true
            muteMixerNodes[currentPlayingCombinationIndex].outputVolume = 0
        }

        composition.combinations[index].isMuted = false
        muteMixerNodes[index].outputVolume = 1
        self.currentPlayingCombinationIndex = index

        if !metronome.isPlaying {
            metronome.play()
        }
    }

    func stopPlaying() {
        if let currentPlayingCombinationIndex = currentPlayingCombinationIndex {
            composition.combinations[currentPlayingCombinationIndex].isMuted = true
            muteMixerNodes[currentPlayingCombinationIndex].outputVolume = 0

            self.currentPlayingCombinationIndex = nil
        }
        
        metronome.reset()
    }

    private func createNodesForCombinationManager(_ combinationManager: CombinationManager, combination: MutableCombination) {
        let muteMixerNode = AVAudioMixerNode()
        let effectsManager = EffectsManager(effects: combination.effects)

        audioEngineManager.attachNode(muteMixerNode)
        audioEngineManager.connect(combinationManager.outputNode, to: effectsManager.inputNode)
        audioEngineManager.connect(effectsManager.outputNode, to: muteMixerNode)
        audioEngineManager.connect(muteMixerNode, to: mainNode)

        muteMixerNode.outputVolume = combination.isMuted ? 0 : 1
        effectsManager.renderDelegate = self
        combinationManager.renderDelegate = self

        muteMixerNodes.append(muteMixerNode)
        effectsManagers.append(effectsManager)
        combinationManagers.append(combinationManager)
    }
}

extension CompositionRenderManager: CombinationManagerRenderDelegate {
    func combinationManagerDidChangeComposition(_ combinationManager: CombinationManager) {
        delegate?.compositionRenderManagerDidChangeComposition(self)
    }
    
    func combinationManager(_ combinationManager: CombinationManager, shouldUpdateMuteState isMuted: Bool) {
        if let combinationIndex = combinationManagers.firstIndex(where: { $0 === combinationManager }) {
            if let currentPlayingCombinationIndex = currentPlayingCombinationIndex {
                if isMuted, currentPlayingCombinationIndex == combinationIndex {
                    stopPlaying()
                } else if !isMuted {
                    playCombination(atIndex: combinationIndex)
                }
            } else if !isMuted {
                playCombination(atIndex: combinationIndex)
            }
        }

        delegate?.compositionRenderManagerDidUpdateCombinationMuteStates(self)
    }
    
    func combinationManager(_ combinationManager: CombinationManager, shouldChangeOverallVolume volume: Float) {
        mainNode.outputVolume = volume
    }
}

extension CompositionRenderManager: EffectsManagerRenderDelegate {
    func effectsManagerDidUpdateComposition(_ effectsManager: EffectsManager) {
        delegate?.compositionRenderManagerDidChangeComposition(self)
    }
}
