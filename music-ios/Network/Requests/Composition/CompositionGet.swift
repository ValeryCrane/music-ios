import Foundation

extension Requests {
    struct CompositionGet: Request {
        struct Parameters: Encodable {
            let id: Int
        }

        typealias Response = CompositionResponse

        private let request = GET<Parameters, Response>(path: "/composition")

        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
