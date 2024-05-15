import Foundation

extension Requests {
    struct CompositionDelete: Request {
        struct Parameters: Encodable {
            let id: Int
        }

        struct Response: Decodable {
            let success: Bool
        }

        private let request = DELETE<Parameters, Response>(path: "/composition")

        @discardableResult
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
