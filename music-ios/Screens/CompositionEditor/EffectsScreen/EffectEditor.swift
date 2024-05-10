import Foundation
import AVFoundation
import UIKit

final class EffectEditor {

    var inputNode: AVAudioNode {
        effectsManager.inputNode
    }

    var outputNode: AVAudioNode {
        effectsManager.outputNode
    }

    private let effectsManager: EffectsManager
    private let bottomSheetTransition = BottomSheetTransitioningDelegate()

    init(effects: MutableEffects) {
        effectsManager = .init(effects: effects)
    }

    func getViewController() -> UIViewController {
        let viewModel = EffectsViewModel(effectsManager: effectsManager)
        let viewController = EffectsViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = bottomSheetTransition
        return viewController
    }
}
