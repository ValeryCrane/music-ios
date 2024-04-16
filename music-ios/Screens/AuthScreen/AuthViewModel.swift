import Foundation
import UIKit

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published
    var username: String = ""
    
    @Published
    var password: String = ""
    
    weak var viewController: UIViewController?
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func onAuthButtonPressed() {
        Task {
            viewController?.startLoader()
            do {
                try await authManager.auth(username: username, password: password)
            } catch {
                print(error.localizedDescription)
                viewController?.stopLoader()
            }
        }
    }
    
    func onRegisterButtonPressed() {
        viewController?.navigationController?.pushViewController(
            RegistrationViewController(authManager: authManager),
            animated: true
        )
    }
}
