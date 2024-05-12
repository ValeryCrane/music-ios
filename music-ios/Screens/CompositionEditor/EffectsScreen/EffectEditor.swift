import Foundation
import AVFoundation
import UIKit

final class EffectEditor {
    private let effectsManager: EffectsManager
    private let bottomSheetTransition = BottomSheetTransitioningDelegate()

    init(effectsManager: EffectsManager) {
        self.effectsManager = effectsManager
    }

    func getViewController() -> UIViewController {
        let viewModel = EffectsViewModel(effectsManager: effectsManager)
        let viewController = EffectsViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = bottomSheetTransition
        return viewController
    }
}
