import Foundation

extension Requests {
    struct UserGet: Request {
        struct Parameters: Encodable {
            let id: Int
        }
        
        typealias Response = UserResponse
        
        private let request = GET<Parameters, Response>(path: "/user")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}

