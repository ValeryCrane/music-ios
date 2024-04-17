import Foundation
import UIKit
import SwiftUI

final class EditProfileViewController: UIHostingController<EditProfileView> {
    
    private let viewModel: EditProfileViewModel
    
    init(userManager: UserManager) {
        let viewModel = EditProfileViewModel(userManager: userManager)
        let rootView = EditProfileView(viewModel: viewModel)
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
        title = "Редактировать"
        navigationItem.leftBarButtonItem = .init(
            title: "Отмена",
            style: .plain,
            target: self,
            action: #selector(cancelButtonPressed(_:))
        )
    }
    
    @objc
    private func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
