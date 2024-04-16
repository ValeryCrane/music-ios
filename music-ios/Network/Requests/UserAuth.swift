import Foundation

extension Requests {
    struct UserAuth: Request {
        struct Parameters: Encodable {
            let username: String
            let password: String
        }
        
        struct Response: Decodable {
            let authToken: String
            
            enum CodingKeys: String, CodingKey {
                case authToken = "auth_token"
            }
        }
        
        private let request = POST<Parameters, Response>(path: "/user/auth")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironmentManager().provideEnvironment())
        }
    }
}
