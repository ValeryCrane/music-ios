import Foundation

extension Requests {
    struct FavouriteCompositionAdd: Request {
        struct Parameters: Encodable {
            let id: Int
        }
        
        struct Response: Decodable {
            let success: Bool
        }
        
        private let request = POST<Parameters, Response>(path: "/favourite/composition")
        
        @discardableResult
        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
