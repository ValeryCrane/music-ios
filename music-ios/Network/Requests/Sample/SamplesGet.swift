import Foundation

extension Requests {
    struct SamplesGet: Request {
        struct Parameters: Encodable { }
        
        struct Response: Decodable {
            let sampleCount: Int
            let samples: [SampleMiniatureResponse]
            
            private enum CodingKeys: String, CodingKey {
                case sampleCount = "sample_count"
                case samples
            }
        }
        
        private let request = GET<Parameters, Response>(path: "/samples")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}

