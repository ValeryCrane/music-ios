import Foundation

struct AuthToken: Codable {
    let userId: Int
    let value: String
}

extension AuthToken {
    init(from userAuthResponse: Requests.UserAuth.Response) {
        self.init(userId: userAuthResponse.userId, value: userAuthResponse.authToken)
    }
    
    init(from userRegisterResponse: Requests.UserRegister.Response) {
        self.init(userId: userRegisterResponse.userId, value: userRegisterResponse.authToken)
    }
}
