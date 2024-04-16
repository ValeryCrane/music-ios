import Foundation

struct CurrentUser: Codable {
    let id: Int
    let username: String
    let email: String
    let compositionCount: Int
    let avatarURL: URL
}

extension CurrentUser {
    init(from userCurrentGetResponse: Requests.UserCurrentGet.Response) {
        self.init(
            id: userCurrentGetResponse.id,
            username: userCurrentGetResponse.username,
            email: userCurrentGetResponse.email,
            compositionCount: userCurrentGetResponse.compositionCount,
            avatarURL: userCurrentGetResponse.avatarURL
        )
    }
}
