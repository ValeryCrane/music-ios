import Foundation
import UIKit

final class CompositionHistoryScreen {
    private let composition: MutableComposition
    private let compositionParametersManager: CompositionParametersManager

    init(composition: MutableComposition, compositionParametersManager: CompositionParametersManager) {
        self.composition = composition
        self.compositionParametersManager = compositionParametersManager
    }

    func getViewController() -> UIViewController {
        let viewModel = CompositionHistoryViewModel(
            composition: composition, 
            compositionParametersManager: compositionParametersManager
        )

        let viewController = CompositionHistoryViewController(viewModel: viewModel)
        viewModel.view = viewController
        return viewController
    }
}
