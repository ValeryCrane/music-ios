import Foundation
import UIKit

protocol TokenManagerDelegate: AnyObject {
    func tokenUpdated(_ token: String?)
}

final class TokenManager {
    weak var delegate: TokenManagerDelegate?
    
    @Stored(key: "TokenManager.token", defaultValue: nil)
    private(set) var token: String? {
        didSet {
            NetworkEnvironmentManager.shared.updateToken(token)
            delegate?.tokenUpdated(token)
        }
    }
    
    private let userAuth = Requests.UserAuth()
    private let userRegister = Requests.UserRegister()
    
    func auth(username: String, password: String) async throws {
        let token = try await userAuth.run(with: .init(username: username, password: password)).authToken
        self.token = token
    }
    
    func register(username: String, email: String, password: String, avatar: UIImage? = nil) async throws {
        let token = try await userRegister.run(with: .init(
            username: username,
            email: email,
            password: password
        )).authToken
        
        self.token = token
    }
    
    func logout() {
        token = nil
    }
    
}
