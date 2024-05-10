import Foundation

extension Requests {
    struct KeyboardsGet: Request {
        struct Parameters: Encodable { }

        struct Response: Decodable {
            let keyboardCount: Int
            let keyboards: [KeyboardMiniatureResponse]

            private enum CodingKeys: String, CodingKey {
                case keyboardCount = "keyboard_count"
                case keyboards
            }
        }

        private let request = GET<Parameters, Response>(path: "/keyboards")

        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}

