import Foundation

enum NetworkEnvironments {
    static var `default`: NetworkEnvironment {
        let authToken = AuthTokenProvider().token
        return .init(
            scheme: "http",
            host: "localhost",
            port: 80,
            commonHeaders: {
                if let authToken = authToken?.value {
                    return ["Auth": authToken]
                } else {
                    return [:]
                }
            }()
        )
    }
}
