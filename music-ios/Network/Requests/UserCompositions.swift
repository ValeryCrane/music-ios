import Foundation

extension Requests {
    struct UserCompositions: Request {
        struct Parameters: Encodable {
            let id: Int
        }
        
        struct Response: Decodable {
            let compositionCount: Int
            let compositions: [CompositionMiniatureResponse]
            
            private enum CodingKeys: String, CodingKey {
                case compositionCount = "composition_count"
                case compositions
            }
        }
        
        private let request = GET<Parameters, Response>(path: "/user/compositions")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironmentManager.shared.provideEnvironment())
        }
    }
}


