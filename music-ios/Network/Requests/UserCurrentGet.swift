import Foundation

extension Requests {
    struct UserCurrentGet: Request {
        struct Parameters: Encodable {}
        
        struct Response: Decodable {
            let id: Int
            let username: String
            let email: String
            let compositionCount: Int
            let avatarURL: URL
            
            private enum CodingKeys: String, CodingKey {
                case id
                case username
                case email
                case compositionCount = "composition_count"
                case avatarURL = "avatar_url"
            }
        }
        
        private let request = GET<Parameters, Response>(path: "/user")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironmentManager().provideEnvironment())
        }
    }
}


