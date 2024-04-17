import Foundation
import UIKit

enum UserManagerError: Error {
    case unauthorized(message: String)
}

final class UserManager {
    private let authTokenProvider = AuthTokenProvider()
    
    private let userCurrentGet = Requests.UserCurrentGet()
    private let userGet = Requests.UserGet()
    private let userEdit = Requests.UserEdit()
    private let userAvatarEdit = Requests.UserAvatarEdit()
    private let userCompositions = Requests.UserCompositions()
    private let userDelete = Requests.UserDelete()
    
    func loadUser(id: Int) async throws -> User {
        let userGetResponse = try await userGet.run(with: .init(id: id))
        return .init(from: userGetResponse)
    }
    
    func loadCurrentUser() async throws -> CurrentUser {
        let userCurrentGetResponse = try await userCurrentGet.run(with: .init())
        return .init(from: userCurrentGetResponse)
    }
    
    func loadUserCompositions(userId: Int? = nil) async throws -> [CompositionMiniature] {
        if let userId = userId ?? authTokenProvider.token?.userId {
            let userCompositionsResponse = try await userCompositions.run(with: .init(id: userId))
            return userCompositionsResponse.compositions.map({ .init(from: $0) })
        } else {
            throw UserManagerError.unauthorized(message: "Current user is unauthorized")
        }
    }
    
    func editCurrentUser(
        username: String? = nil,
        email: String? = nil,
        password: String? = nil,
        avatar: UIImage? = nil
    ) async throws {
        if username != nil || email != nil || password != nil {
            try await userEdit.run(with: .init(username: username, email: email, password: password))
        }
        
        if let avatar = avatar {
            try await userAvatarEdit.run(with: avatar)
        }
    }
    
    func deleteCurrentUser() async throws {
        try await userDelete.run(with: .init())
        AuthTokenProvider.updateAuthToken(nil)
    }
}
