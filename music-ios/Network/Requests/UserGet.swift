import Foundation

extension Requests {
    struct UserGet: Request {
        struct Parameters: Encodable {
            let id: Int
        }
        
        struct Response: Decodable {
            let id: Int
            let username: String
            let compositionCount: Int
            let avatarURL: URL
            let isFavourite: Bool
            
            private enum CodingKeys: String, CodingKey {
                case id
                case username
                case compositionCount = "composition_count"
                case avatarURL = "avatar_url"
                case isFavourite = "is_favourite"
            }
        }
        
        private let request = GET<Parameters, Response>(path: "/user")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironmentManager().provideEnvironment())
        }
    }
}

