import Foundation

extension Requests {
    struct MelodyGet: Request {
        struct Parameters: Encodable {
            let id: Int
        }

        struct Response: Decodable {
            let id: Int
            let name: String
            let keyboardId: Int
            let blueprint: String

            private enum CodingKeys: String, CodingKey {
                case id
                case name
                case keyboardId = "keyboard_id"
                case blueprint
            }
        }

        private let request = GET<Parameters, Response>(path: "/melody")

        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}

