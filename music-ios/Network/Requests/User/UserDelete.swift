import Foundation

extension Requests {
    struct UserDelete: Request {
        struct Parameters: Encodable { }
        
        struct Response: Decodable {
            let success: Bool
        }
        
        private let request = DELETE<Parameters, Response>(path: "/user")
        
        @discardableResult
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
