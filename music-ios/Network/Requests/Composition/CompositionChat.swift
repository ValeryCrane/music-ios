import Foundation

extension Requests {
    struct CompositionChat: Request {
        struct Parameters: Encodable {
            let compositionId: Int
            let lastMessageId: Int?

            private enum CodingKeys: String, CodingKey {
                case compositionId = "composition_id"
                case lastMessageId = "last_message_id"
            }
        }

        struct Response: Decodable {
            let messages: [MessageResponse]
        }

        private let request = GET<Parameters, Response>(path: "/composition/chat")

        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
