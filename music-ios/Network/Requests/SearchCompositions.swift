import Foundation

extension Requests {
    struct SearchCompositions: Request {
        struct Parameters: Encodable {
            let query: String
            let page: Int
        }
        
        struct Response: Decodable {
            let compositionCount: Int
            let page: Int
            let totalPages: Int
            let compositions: [CompositionMiniatureResponse]
            
            private enum CodingKeys: String, CodingKey {
                case compositionCount = "composition_count"
                case page
                case totalPages = "total_pages"
                case compositions
            }
        }
        
        private let request = GET<Parameters, Response>(path: "/search/compositions")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}

