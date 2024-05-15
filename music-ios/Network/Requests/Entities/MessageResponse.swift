import Foundation

struct MessageResponse: Decodable {
    let id: Int
    let user: UserResponse
    let isOwn: Bool
    let text: String
    let unixTime: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case user
        case isOwn = "is_own"
        case text
        case unixTime = "unix_time"
    }
}
