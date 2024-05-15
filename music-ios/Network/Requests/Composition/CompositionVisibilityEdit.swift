import Foundation

extension Requests {
    struct CompositionVisibilityEdit: Request {
        struct Parameters: Encodable {
            let id: Int
            let visibility: CompositionVisibility
        }

        struct Response: Decodable {
            let success: Bool
        }

        private let request = PATCH<Parameters, Response>(path: "/composition/visibility")

        @discardableResult
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
