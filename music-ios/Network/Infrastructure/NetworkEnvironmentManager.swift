import Foundation

final class NetworkEnvironmentManager {
    static let shared = NetworkEnvironmentManager()
    
    private var token: String? = nil
    
    func provideEnvironment() -> NetworkEnvironment {
        .init(
            scheme: "http",
            host: "localhost",
            port: 80,
            commonHeaders: {
                if let token {
                    return ["Auth": token]
                } else {
                    return [:]
                }
            }()
        )
    }
    
    func updateToken(_ token: String?) {
        self.token = token
    }
}
