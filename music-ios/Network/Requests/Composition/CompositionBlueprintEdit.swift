import Foundation

extension Requests {
    struct CompositionBlueprintEdit: Request {
        struct Parameters: Encodable {
            let id: Int
            let blueprint: String
        }

        struct Response: Decodable {
            let success: Bool
        }

        private let request = PATCH<Parameters, Response>(path: "/composition/blueprint")

        @discardableResult
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
