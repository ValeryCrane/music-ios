import Foundation
import UIKit

final class AuthManager {
    
    private let userAuth = Requests.UserAuth()
    private let userRegister = Requests.UserRegister()
    
    func auth(username: String, password: String) async throws {
        let authTokenResponse = try await userAuth.run(with: .init(username: username, password: password))
        let authToken = AuthToken(from: authTokenResponse)
        AuthTokenProvider.updateAuthToken(authToken)
    }
    
    func register(username: String, email: String, password: String, avatar: UIImage? = nil) async throws {
        let authTokenResponse = try await userRegister.run(with: .init(
            username: username,
            email: email,
            password: password
        ))
        let authToken = AuthToken(from: authTokenResponse)
        AuthTokenProvider.updateAuthToken(authToken)
    }
    
    func logout() {
        AuthTokenProvider.updateAuthToken(nil)
    }
}
