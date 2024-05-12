import Foundation
import UIKit
import AVFoundation

final class MelodyEditor {
    private let internalMetronome: Metronome

    private let effectsManager: EffectsManager
    private let melodyManager: MelodyManager
    private let audioEngineManager = AudioEngineManager()

    private var externalMetronomeWasPlaying: Bool?
    private var externalMetronome: Metronome?

    init(melodyManager: MelodyManager, effectsManager: EffectsManager) {
        self.melodyManager = melodyManager
        self.effectsManager = effectsManager
        self.internalMetronome = .init(bpm: melodyManager.metronome.bpm)
    }

    func getViewController() -> UIViewController {
        let viewModel = EditMelodyViewModel(
            metronome: internalMetronome,
            melodyManager: melodyManager,
            effectsManager: effectsManager
        )

        let viewController = EditMelodyViewController(viewModel: viewModel)
        viewModel.view = viewController
        viewModel.delegate = self

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
}

extension MelodyEditor: EditMelodyViewModelDelegate {
    func editMelodyViewModelStartedEditing(_ editMelodyViewModel: EditMelodyViewModel) {
        externalMetronome = melodyManager.metronome
        externalMetronomeWasPlaying = melodyManager.metronome.isPlaying
        melodyManager.metronome.pause()

        internalMetronome.updateBPM(melodyManager.metronome.bpm)
        melodyManager.setMuteState(isMuted: false)
        melodyManager.setMetronome(internalMetronome)
    }
    
    func editMelodyViewModelEndedEditing(_ editMelodyViewModel: EditMelodyViewModel) {
        if let externalMetronome = externalMetronome, let externalMetronomeWasPlaying = externalMetronomeWasPlaying {
            melodyManager.setMetronome(externalMetronome)
            internalMetronome.reset()
            if externalMetronomeWasPlaying {
                externalMetronome.play()
            }

            self.externalMetronome = nil
            self.externalMetronomeWasPlaying = nil
        }
    }
}
