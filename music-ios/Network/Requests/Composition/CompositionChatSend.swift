import Foundation

extension Requests {
    struct CompositionChatSend: Request {
        struct Parameters: Encodable {
            let compositionId: Int
            let message: String
        }

        struct Response: Decodable {
            let success: Bool
        }

        private let request = POST<Parameters, Response>(path: "/composition/chat/send")

        @discardableResult
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
