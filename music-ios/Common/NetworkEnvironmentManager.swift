import Foundation

final class NetworkEnvironmentManager {
    private let authManager = AuthManager()
    
    func provideEnvironment() -> NetworkEnvironment {
        .init(
            scheme: "http",
            host: "localhost",
            port: 80,
            commonHeaders: {
                if let token = authManager.token {
                    return ["Auth": token]
                } else {
                    return [:]
                }
            }()
        )
    }
}
