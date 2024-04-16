import Foundation

struct User {
    let id: Int
    let username: String
    let compositionCount: Int
    let avatarURL: URL
    let isFavourite: Bool
}

extension User {
    init(from userGetResponse: Requests.UserGet.Response) {
        self.init(
            id: userGetResponse.id,
            username: userGetResponse.username,
            compositionCount: userGetResponse.compositionCount,
            avatarURL: userGetResponse.avatarURL,
            isFavourite: userGetResponse.isFavourite
        )
    }
}
