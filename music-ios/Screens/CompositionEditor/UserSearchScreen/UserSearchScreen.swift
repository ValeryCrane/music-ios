import Foundation
import UIKit

final class UserSearchScreen {
    private let ignoredUserIds: Set<Int>
    private let chooseUserHandler: (User) async -> Void

    init(
        ignoredUserIds: Set<Int>,
        chooseUserHandler: @escaping (User) async -> Void
    ) {
        self.ignoredUserIds = ignoredUserIds
        self.chooseUserHandler = chooseUserHandler
    }

    func getViewController() -> UIViewController {
        let viewModel = UserSearchViewModel(ignoredUserIds: ignoredUserIds, chooseUserHandler: chooseUserHandler)
        let viewController = UserSearchViewController(viewModel: viewModel)
        viewModel.view = viewController
        return UINavigationController(rootViewController: viewController)
    }
}
