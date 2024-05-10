import Foundation
import UIKit

final class ChooseKeyboard {
    let currentKeyboard: KeyboardMiniature
    let completion: (KeyboardMiniature?) -> Void

    init(
        currentKeyboard: KeyboardMiniature,
        completion: @escaping (KeyboardMiniature?) -> Void
    ) {
        self.currentKeyboard = currentKeyboard
        self.completion = completion
    }

    func getViewController() -> UIViewController {
        let viewModel = ChooseKeyboardViewModel(currentKeyboard: currentKeyboard, completion: completion)
        let viewController = ChooseKeyboardViewController(viewModel: viewModel)
        viewModel.view = viewController
        
        return UINavigationController(rootViewController: viewController)
    }
}
