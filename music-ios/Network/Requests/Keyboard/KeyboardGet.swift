import Foundation

extension Requests {
    struct KeyboardGet: Request {
        struct Parameters: Encodable { 
            let id: Int
        }
        
        struct Response: Decodable {
            let id: Int
            let name: String
            let keySampleIds: [Int]
            
            private enum CodingKeys: String, CodingKey {
                case id
                case name
                case keySampleIds = "key_sample_ids"
            }
        }
        
        private let request = GET<Parameters, Response>(path: "/keyboard")
        
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}

