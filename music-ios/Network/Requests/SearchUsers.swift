import Foundation

extension Requests {
    struct SearchUsers: Request {
        struct Parameters: Encodable { 
            let query: String
            let page: Int
        }
        
        struct Response: Decodable {
            let userCount: Int
            let page: Int
            let totalPages: Int
            let users: [UserResponse]
            
            private enum CodingKeys: String, CodingKey {
                case userCount = "user_count"
                case page
                case totalPages = "total_pages"
                case users
            }
        }
        
        private let request = GET<Parameters, Response>(path: "/search/users")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
