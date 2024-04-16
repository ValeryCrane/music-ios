import Foundation

protocol AuthManagerDelegate: AnyObject {
    func tokenUpdated(_ token: String?)
}

final class AuthManager {
    weak var delegate: AuthManagerDelegate?
    
    @Stored(key: "AuthManager.token", defaultValue: nil)
    private(set) var token: String? {
        didSet {
            delegate?.tokenUpdated(token)
        }
    }
    
    private let userAuth = Requests.UserAuth()
    
    func auth(username: String, password: String) async throws {
        let token = try await userAuth.run(with: .init(username: username, password: password)).authToken
        self.token = token
    }
    
}
