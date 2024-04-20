import Foundation

extension Requests {
    struct MelodiesGet: Request {
        struct Parameters: Encodable { }
        
        struct Response: Decodable {
            let melodyCount: Int
            let melodies: [MelodyMiniatureResponse]
            
            private enum CodingKeys: String, CodingKey {
                case melodyCount = "melody_count"
                case melodies
            }
        }
        
        private let request = GET<Parameters, Response>(path: "/melodies")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}

