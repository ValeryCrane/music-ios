import Foundation

struct User {
    let id: Int
    let username: String
    let compositionCount: Int
    let avatarURL: URL
    let isFavourite: Bool
}

extension User {
    init(from userResponse: UserResponse) {
        self.init(
            id: userResponse.id,
            username: userResponse.username,
            compositionCount: userResponse.compositionCount,
            avatarURL: userResponse.avatarURL,
            isFavourite: userResponse.isFavourite
        )
    }
}
