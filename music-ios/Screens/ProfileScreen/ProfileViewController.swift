import Foundation
import UIKit
import SwiftUI

final class ProfileViewController: UIHostingController<ProfileView> {
    
    init(userManager: UserManager, userId: Int? = nil) {
        let rootViewModel = ProfileViewModel(userManager: userManager, userId: userId)
        let rootView = ProfileView(viewModel: rootViewModel)
        
        super.init(rootView: rootView)
        
        rootViewModel.viewController = self
        title = "Профиль"
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
