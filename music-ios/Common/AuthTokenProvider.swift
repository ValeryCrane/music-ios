import Foundation
import UIKit

extension Notification.Name {
    static let onAuthTokenUpdated = Notification.Name("Notification.Name.onAuthTokenUpdated")
}

protocol AuthTokenProviderDelegate: AnyObject {
    func authTokenProvider(authTokenUpdated authToken: AuthToken?)
}

final class AuthTokenProvider {
    
    static func updateAuthToken(_ authToken: AuthToken?) {
        Self.authToken = authToken
        NotificationCenter.default.post(
            name: .onAuthTokenUpdated,
            object: nil,
            userInfo: ["auth_token": authToken as Any]
        )
    }
    
    @Stored(key: "TokenManager.authToken", defaultValue: nil)
    private static var authToken: AuthToken?
    
    weak var delegate: AuthTokenProviderDelegate?
    
    var token: AuthToken? {
        Self.authToken
    }
    
    init() {
        NotificationCenter.default.addObserver(
            self, 
            selector: #selector(onAuthTokenUpdated(_:)),
            name: .onAuthTokenUpdated,
            object: nil
        )
    }
    
    @objc
    private func onAuthTokenUpdated(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let authToken = userInfo["auth_token"] as? AuthToken {
            delegate?.authTokenProvider(authTokenUpdated: authToken)
        } else {
            delegate?.authTokenProvider(authTokenUpdated: nil)
        }
    }
}
