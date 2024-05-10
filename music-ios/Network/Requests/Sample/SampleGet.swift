import Foundation

extension Requests {
    struct SampleGet: Request {
        struct Parameters: Encodable { 
            let id: Int
        }
        
        typealias Response = Data
        
        private let request = DATA<Parameters>(path: "/sample")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}

