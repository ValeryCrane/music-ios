import Foundation

extension Requests {
    struct CompositionHistoryGet: Request {
        struct Parameters: Encodable {
            let id: Int
        }

        struct Response: Decodable {
            let blueprintCount: Int
            let blueprints: [Blueprint]

            struct Blueprint: Decodable {
                let id: Int
                let parentId: Int?
                let creator: UserResponse

                private enum CodingKeys: String, CodingKey {
                    case id
                    case parentId = "parent_id"
                    case creator
                }
            }

            private enum CodingKeys: String, CodingKey {
                case blueprintCount = "blueprint_count"
                case blueprints
            }
        }

        private let request = GET<Parameters, Response>(path: "/composition/history")

        func run(with parameters: Parameters) async throws -> Response {
            try await request.run(with: parameters, environment: NetworkEnvironments.default)
        }
    }
}
