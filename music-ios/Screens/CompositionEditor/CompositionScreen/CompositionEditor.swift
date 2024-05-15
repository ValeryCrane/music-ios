import Foundation
import UIKit

final class CompositionEditor {
    private let compositionManager: CompositionRenderManager
    private let compositionParametersScreen: CompositionParametersScreen

    init(compositionManager: CompositionRenderManager, compositionParametersScreen: CompositionParametersScreen) {
        self.compositionManager = compositionManager
        self.compositionParametersScreen = compositionParametersScreen
    }

    func getViewController() -> UIViewController {
        let viewModel = CompositionViewModel(
            compositionManager: compositionManager,
            compositionParametersScreen: compositionParametersScreen
        )
        let viewController = CompositionViewController(viewModel: viewModel)
        viewModel.view = viewController

        let navigationController = CompositionNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.output = viewModel
        viewModel.toolbarManager = navigationController
        return navigationController
    }
}
