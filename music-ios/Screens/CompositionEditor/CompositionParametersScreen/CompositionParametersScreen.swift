import Foundation
import UIKit

final class CompositionParametersScreen {
    private let composition: MutableComposition
    private let onCompositionDeleted: () -> Void

    init(composition: MutableComposition, onCompositionDeleted: @escaping () -> Void) {
        self.composition = composition
        self.onCompositionDeleted = onCompositionDeleted
    }

    func getViewController() -> UIViewController {
        let viewModel = CompositionParametersViewModel(
            composition: composition,
            compositionParametersManager: CompositionParametersManager(),
            onCompositionDeleted: {}
        )
        let viewController = CompositionParametersViewController(viewModel: viewModel)
        viewModel.view = viewController
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen

        return navigationController
    }
}
