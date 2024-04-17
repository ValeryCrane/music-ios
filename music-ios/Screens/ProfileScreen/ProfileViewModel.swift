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
    
    @Published
    var isLogoutConfirmationPresented: Bool = false
    
    weak var viewController: UIViewController?
    
    private let authTokenProvider = AuthTokenProvider()
    private let userManager: UserManager
    private let userId: Int?
    
    init(userManager: UserManager, userId: Int? = nil) {
        self.userManager = userManager
        self.userId = userId
    }
    
    func loadUser() async throws {
        guard let userId = userId else {
            try await loadCurrentUser()
            return
        }
        
        let user = try await userManager.loadUser(id: userId)
        
        if authTokenProvider.token?.userId == user.id {
            try await loadCurrentUser()
        } else {
            updateUserInfo(withUser: user)
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
    
    
    func onEditButtonPressed() {
        // TODO
    }
    
    func onLogoutButtonPressed() {
        isLogoutConfirmationPresented = true
    }
    
    func onLogoutConfirmed() {
        AuthTokenProvider.updateAuthToken(nil)
    }
    
    private func loadCurrentUser() async throws {
        let currentUser = try await userManager.loadCurrentUser()
        updateUserInfo(withCurrentUser: currentUser)
    }
    
    private func updateUserInfo(withUser user: User) {
        isCurrentUser = false
        avatarURL = user.avatarURL
        username = user.username
        email = nil
        compositionCount = user.compositionCount
        isFavourite = user.isFavourite
    }
    
    private func updateUserInfo(withCurrentUser currentUser: CurrentUser) {
        isCurrentUser = true
        avatarURL = currentUser.avatarURL
        username = currentUser.username
        email = currentUser.email
        compositionCount = currentUser.compositionCount
        isFavourite = nil
    }
}
