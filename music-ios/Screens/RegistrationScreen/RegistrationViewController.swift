import Foundation
import UIKit
import SwiftUI

final class RegistrationViewController: UIHostingController<RegistrationView> {
    
    init(tokenManager: TokenManager) {
        let rootViewModel = RegistrationViewModel(tokenManager: tokenManager)
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
