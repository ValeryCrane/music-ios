import Foundation
import UIKit

final class CombinationEditor {
    private let combinationManager: CombinationManager
    private let effectsManager: EffectsManager

    init(combinationManager: CombinationManager, effectsManager: EffectsManager) {
        self.combinationManager = combinationManager
        self.effectsManager = effectsManager
    }

    func getViewController() -> UIViewController {
        let viewModel = CombinationViewModel(combinationManager: combinationManager, effectsManager: effectsManager)
        let viewController = CombinationViewController(viewModel: viewModel)
        viewModel.view = viewController
        return viewController
    }
}
