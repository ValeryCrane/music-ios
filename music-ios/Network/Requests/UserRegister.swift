import Foundation

extension Requests {
    struct UserRegister: Request {
        struct Parameters: Encodable {
            let username: String
            let email: String
            let password: String
        }
        
        struct Response: Decodable {
            let userId: Int
            let authToken: String
            
            private enum CodingKeys: String, CodingKey {
                case userId = "user_id"
                case authToken = "auth_token"
            }
        }
        
        private let request = POST<Parameters, Response>(path: "/user/register")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}

