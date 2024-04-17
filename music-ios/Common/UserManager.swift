import Foundation

enum UserManagerError: Error {
    case unauthorized(message: String)
}

protocol UserManagerDelegate: AnyObject {
    func currentUserUpdated(_ currentUser: CurrentUser?)
}

final class UserManager {
    weak var delegate: UserManagerDelegate?
    
    @Stored(key: "UserManager.currentUser", defaultValue: nil)
    private(set) var currentUser: CurrentUser? {
        didSet {
            delegate?.currentUserUpdated(currentUser)
        }
    }
    
    private let userCurrentGet = Requests.UserCurrentGet()
    private let userGet = Requests.UserGet()
    
    private let userCompositions = Requests.UserCompositions()
    
    func loadUser(id: Int) async throws -> User {
        let userGetResponse = try await userGet.run(with: .init(id: id))
        return .init(from: userGetResponse)
    }
    
    func loadUserCompositions(userId: Int? = nil) async throws -> [CompositionMiniature] {
        if let userId = userId ?? currentUser?.id {
            let userCompositionsResponse = try await userCompositions.run(with: .init(id: userId))
            return userCompositionsResponse.compositions.map({ .init(from: $0) })
        } else {
            throw UserManagerError.unauthorized(message: "Current user is unauthorized")
        }
    }
    
    private func updateCurrentUser(token: String?) async throws {
        guard token != nil else {
            currentUser = nil
            return
        }
        
        let userCurrentGetResponse = try await userCurrentGet.run(with: .init())
        currentUser = .init(from: userCurrentGetResponse)
    }
    
}

extension UserManager: TokenManagerDelegate {
    func tokenUpdated(_ token: String?) {
        Task {
            try await updateCurrentUser(token: token)
        }
    }
}
