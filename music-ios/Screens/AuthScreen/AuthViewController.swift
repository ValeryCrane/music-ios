import Foundation
import UIKit
import SwiftUI

final class AuthViewController: UIHostingController<AuthView> {
    
    init(authManager: AuthManager) {
        let rootViewModel = AuthViewModel(authManager: authManager)
        let rootView = AuthView(viewModel: rootViewModel)
        
        super.init(rootView: rootView)
        
        rootViewModel.viewController = self
        title = "Вход"
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
