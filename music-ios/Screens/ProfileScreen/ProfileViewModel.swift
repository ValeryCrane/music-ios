import Foundation
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published
    var isCurrentUser: Bool? = nil
    
    @Published
    var avatarURL: URL? = nil
    
    @Published
    var username: String? = nil
    
    @Published
    var email: String? = nil
    
    @Published
    var compositionCount: Int? = nil
    
    @Published
    var isFavourite: Bool? = nil
    
    @Published
    var compositions: [CompositionMiniature]? = nil
    
    weak var viewController: UIViewController?
    
    private let userManager: UserManager
    private let userId: Int?
    
    init(userManager: UserManager, userId: Int? = nil) {
        self.userManager = userManager
        self.userId = userId
    }
    
    func loadUser() async throws {
        if let userId = userId {
            let user = try await userManager.loadUser(id: userId)
            if userManager.currentUser?.id == user.id {
                loadCurrentUserIfPossible()
            } else {
                isCurrentUser = false
                avatarURL = user.avatarURL
                username = user.username
                email = nil
                compositionCount = user.compositionCount
                isFavourite = user.isFavourite
            }
        } else {
            loadCurrentUserIfPossible()
        }
    }
    
    func loadUser() {
        Task {
            try await loadUser()
        }
    }
    
    func loadCompositions() {
        Task {
            compositions = try await userManager.loadUserCompositions(userId: userId)
        }
    }
    
    private func loadCurrentUserIfPossible() {
        isCurrentUser = true
        avatarURL = userManager.currentUser?.avatarURL
        username = userManager.currentUser?.username
        email = userManager.currentUser?.email
        compositionCount = userManager.currentUser?.compositionCount
        isFavourite = nil
    }
}
