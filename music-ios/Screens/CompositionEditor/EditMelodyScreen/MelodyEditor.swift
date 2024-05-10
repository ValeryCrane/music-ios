import Foundation
import UIKit
import AVFoundation

final class MelodyEditor {
    var outputNode: AVAudioNode {
        effectEditor.outputNode
    }

    private(set) var isMuted: Bool
    private var isEditing: Bool

    private let metronome: Metronome
    private let internalMetronome: Metronome
    private let effectEditor: EffectEditor
    private let melodyManager: MelodyManager
    private let audioEngineManager = AudioEngineManager()

    init(metronome: Metronome, melody: MutableMelody) async throws {
        self.metronome = metronome
        self.internalMetronome = .init(bpm: metronome.bpm)
        self.effectEditor = .init(effects: melody.effects)
        self.melodyManager = try await .init(
            melody: melody,
            metronome: metronome
        )

        self.isEditing = false
        self.isMuted = melodyManager.isMuted

        audioEngineManager.connect(melodyManager.outputNode, to: effectEditor.inputNode)
        // TODO: Не добавлять вручную
        audioEngineManager.addNodeToMainMixer(effectEditor.outputNode)
    }

    func getViewController() -> UIViewController {
        let viewModel = EditMelodyViewModel(
            metronome: internalMetronome,
            melodyManager: melodyManager,
            effectsEditor: effectEditor
        )
        let viewController = EditMelodyViewController(viewModel: viewModel)
        viewModel.view = viewController
        viewModel.delegate = self
        return UINavigationController(rootViewController: viewController)
    }

    func getEffectsViewController() -> UIViewController {
        effectEditor.getViewController()
    }

    func setMuteState(isMuted: Bool) {
        self.isMuted = isMuted
        if !isEditing {
            melodyManager.setMuteState(isMuted: isMuted)
        }
    }
}

extension MelodyEditor: EditMelodyViewModelDelegate {
    func editMelodyViewModelStartedEditing(_ editMelodyViewModel: EditMelodyViewModel) {
        melodyManager.setMuteState(isMuted: false)
        melodyManager.setMetronome(internalMetronome)
        isEditing = true
    }
    
    func editMelodyViewModelEndedEditing(_ editMelodyViewModel: EditMelodyViewModel) {
        melodyManager.setMuteState(isMuted: isMuted)
        melodyManager.setMetronome(metronome)
        isEditing = false
    }
}
