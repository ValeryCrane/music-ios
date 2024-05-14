import Foundation
import UIKit
import AVFoundation

final class MelodyEditor {
    private let internalMetronome: Metronome
    private let effectsManager: EffectsManager
    private let melodyManager: MelodyManager
    private let onClose: () -> Void

    init(
        internalMetronome: Metronome,
        melodyManager: MelodyManager,
        effectsManager: EffectsManager,
        onClose: @escaping () -> Void
    ) {
        self.internalMetronome = internalMetronome
        self.melodyManager = melodyManager
        self.effectsManager = effectsManager
        self.onClose = onClose
    }

    func getViewController() -> UIViewController {
        let viewModel = EditMelodyViewModel(
            metronome: internalMetronome,
            melodyManager: melodyManager,
            effectsManager: effectsManager,
            onClose: onClose
        )

        let viewController = EditMelodyViewController(viewModel: viewModel)
        viewModel.view = viewController

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
}
