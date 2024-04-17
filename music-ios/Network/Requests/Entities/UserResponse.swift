import Foundation

struct UserResponse: Decodable {
    let id: Int
    let username: String
    let compositionCount: String
    let avatarURL: URL
    let isFavourite: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case compositionCount = "composition_count"
        case avatarURL = "avatar_url"
        case isFavourite = "is_favourite"
    }
}
