import Foundation
import UIKit

final class CompositionEditor {
    private let compositionManager: CompositionRenderManager

    init(compositionManager: CompositionRenderManager) {
        self.compositionManager = compositionManager
    }

    func getViewController() -> UIViewController {
        let viewModel = CompositionViewModel(compositionManager: compositionManager)
        let viewController = CompositionViewController(viewModel: viewModel)
        viewModel.view = viewController

        let navigationController = CompositionNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.output = viewModel
        viewModel.toolbarManager = navigationController
        return navigationController
    }
}
