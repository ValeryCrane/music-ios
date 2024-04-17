import Foundation
import UIKit

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published
    var username: String = ""
    
    @Published
    var password: String = ""
    
    weak var viewController: UIViewController?
    
    private let tokenManager: TokenManager
    
    init(tokenManager: TokenManager) {
        self.tokenManager = tokenManager
    }
    
    func onAuthButtonPressed() {
        Task {
            viewController?.startLoader()
            do {
                try await tokenManager.auth(username: username, password: password)
            } catch {
                print(error.localizedDescription)
                viewController?.stopLoader()
            }
        }
    }
    
    func onRegisterButtonPressed() {
        viewController?.navigationController?.pushViewController(
            RegistrationViewController(tokenManager: tokenManager),
            animated: true
        )
    }
}
