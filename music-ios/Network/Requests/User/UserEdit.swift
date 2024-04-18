import Foundation

extension Requests {
    struct UserEdit: Request {
        struct Parameters: Encodable {
            let username: String?
            let email: String?
            let password: String?
        }
        
        struct Response: Decodable {
            let success: Bool
        }
        
        private let request = PATCH<Parameters, Response>(path: "/user")
        
        @discardableResult
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
