import Foundation

extension Requests {
    struct CompositionChatLoad: Request {
        struct Parameters: Encodable {
            let firstMessageId: Int?
            let compositionId: Int

            private enum CodingKeys: String, CodingKey {
                case firstMessageId = "first_message_id"
                case compositionId = "composition_id"
            }
        }

        struct Response: Decodable {
            let messages: [MessageResponse]
            let isLastBatch: Bool

            private enum CodingKeys: String, CodingKey {
                case messages
                case isLastBatch = "is_last_batch"
            }
        }

        private let request = GET<Parameters, Response>(path: "/composition/chat/load")

        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
