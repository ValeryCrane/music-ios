import Foundation
import UIKit

@MainActor
final class RegistrationViewModel: ObservableObject {
    
    @Published
    var username: String = ""
    
    @Published
    var email: String = ""
    
    @Published
    var password: String = ""
    
    @Published
    var repeatedPassword: String = ""
    
    weak var viewController: UIViewController?
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func onRegisterButtonPressed() {
        guard password == repeatedPassword else { return }
        
        Task {
            viewController?.startLoader()
            do {
                try await authManager.register(username: username, email: email, password: password)
            } catch {
                print(error.localizedDescription)
            }
            viewController?.stopLoader()
        }
    }
}
