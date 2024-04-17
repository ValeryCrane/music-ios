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
    
    private let tokenManager: TokenManager
    
    init(tokenManager: TokenManager) {
        self.tokenManager = tokenManager
    }
    
    func onRegisterButtonPressed() {
        guard password == repeatedPassword else { return }
        
        Task {
            viewController?.startLoader()
            do {
                try await tokenManager.register(username: username, email: email, password: password)
            } catch {
                print(error.localizedDescription)
                viewController?.stopLoader()
            }
        }
    }
}
