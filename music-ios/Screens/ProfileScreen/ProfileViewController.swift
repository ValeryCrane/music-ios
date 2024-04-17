import Foundation
import UIKit
import SwiftUI

final class ProfileViewController: UIHostingController<ProfileView> {
    
    private let viewModel: ProfileViewModel
    
    init(userManager: UserManager, userId: Int? = nil) {
        let viewModel = ProfileViewModel(userManager: userManager, userId: userId)
        let rootView = ProfileView(viewModel: viewModel)
        self.viewModel = viewModel
        
        super.init(rootView: rootView)
        
        viewModel.viewController = self
        configureNavigationItem()
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationItem() {
        title = "Профиль"
        
        let editButton = UIBarButtonItem(
            image: .init(systemName: "pencil"), 
            style: .plain,
            target: self,
            action: #selector(editButtonPressed(_:))
        )
        
        let logoutButton = UIBarButtonItem(
            image: .init(systemName: "rectangle.portrait.and.arrow.right"),
            style: .plain,
            target: self,
            action: #selector(logoutButtonPressed(_:))
        )
        
        navigationItem.rightBarButtonItems = [editButton, logoutButton]
    }
    
    @objc
    private func logoutButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.onLogoutButtonPressed()
    }
    
    @objc
    private func editButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.onEditButtonPressed()
    }
}
