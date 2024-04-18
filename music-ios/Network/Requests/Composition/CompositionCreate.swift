import Foundation

extension Requests {
    struct CompositionCreate: Request {
        struct Parameters: Encodable {
            let name: String
        }
        
        typealias Response = CompositionResponse
        
        private let request = POST<Parameters, Response>(path: "/composition")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
