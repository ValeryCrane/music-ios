import Foundation

extension Requests {
    struct FavouriteUsersGet: Request {
        struct Parameters: Encodable { }
        
        struct Response: Decodable {
            let userCount: Int
            let users: [UserResponse]
            
            private enum CodingKeys: String, CodingKey {
                case userCount = "user_count"
                case users
            }
        }
        
        private let request = GET<Parameters, Response>(path: "/favourite/users")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
