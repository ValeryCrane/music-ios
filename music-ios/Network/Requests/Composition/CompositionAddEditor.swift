import Foundation

extension Requests {
    struct CompositionAddEditor: Request {
        struct Parameters: Encodable {
            let id: Int
            let editorId: Int

            private enum CodingKeys: String, CodingKey {
                case id
                case editorId = "editor_id"
            }
        }

        struct Response: Decodable {
            let success: Bool
        }

        private let request = POST<Parameters, Response>(path: "/composition/editor")

        @discardableResult
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
