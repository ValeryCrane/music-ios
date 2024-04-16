import Foundation
import UIKit
import SwiftUI

final class RegistrationViewController: UIHostingController<RegistrationView> {
    
    init(authManager: AuthManager) {
        let rootViewModel = RegistrationViewModel(authManager: authManager)
        let rootView = RegistrationView(viewModel: rootViewModel)
        
        super.init(rootView: rootView)
        
        rootViewModel.viewController = self
        title = "Регистрация"
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
