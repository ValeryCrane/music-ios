import Foundation

extension Requests {
    struct CompositionsGet: Request {
        struct Parameters: Encodable { }
        
        struct Response: Decodable {
            let compositionCount: Int
            let compositions: [CompositionMiniatureResponse]
            
            private enum CodingKeys: String, CodingKey {
                case compositionCount = "composition_count"
                case compositions
            }
        }
        
        private let request = GET<Parameters, Response>(path: "/compositions")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}

