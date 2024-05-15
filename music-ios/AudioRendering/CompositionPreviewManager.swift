import Foundation

final class CompositionPreviewManager {
    private let metronome: Metronome
    private let combinationManager: CombinationManager?
    private let effectsManager: EffectsManager?
    private let audioEngineManager = AudioEngineManager()

    init(composition: Composition) async throws {
        let metronome = Metronome(bpm: Double(composition.bpm))
        if let combination = composition.combinations.first {
            combinationManager = try await .init(combination: .init(combination), metronome: metronome)
            effectsManager = .init(effects: .init(effects: combination.effects))
        } else {
            combinationManager = nil
            effectsManager = nil
        }

        self.metronome = metronome

        if let combinationManager = combinationManager, let effectsManager = effectsManager {
            audioEngineManager.connect(combinationManager.outputNode, to: effectsManager.inputNode)
            audioEngineManager.addNodeToMainMixer(effectsManager.outputNode)
        }
    }

    func play() {
        metronome.play()
    }

    func stop() {
        metronome.reset()
    }
}
