import Foundation
import UIKit

final class ChatScreen {
    private let compositionId: Int

    init(compositionId: Int) {
        self.compositionId = compositionId
    }

    func getViewController() -> UIViewController {
        let chatManager = ChatManager(compositionId: compositionId)
        let chatViewModel = ChatViewModel(chatManager: chatManager)
        let chatViewController = ChatViewController(viewModel: chatViewModel)
        chatViewModel.view = chatViewController
        let navigationController = UINavigationController(rootViewController: chatViewController)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
}
