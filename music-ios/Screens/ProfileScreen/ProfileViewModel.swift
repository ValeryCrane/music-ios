import Foundation
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published
    var isCurrentUser: Bool? = nil
    
    @Published
    var avatarURL: URL? = nil
    
    @Published
    var avatarId: UUID = UUID()
    
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
    var compositionStates: [CompositionMiniatureView.PlayState] = []

    @Published
    var isLogoutConfirmationPresented: Bool = false
    
    weak var viewController: UIViewController?
    
    private let authTokenProvider = AuthTokenProvider()
    private let userManager: UserManager
    private let userId: Int?

    private let favouritesManager = FavouritesManager()
    private let compositionManager = CompositionManager()
    
    private var playingCompositionIndex: Int?
    private var compositionPreviewManager: CompositionPreviewManager?
    private var compositionPreviewLoadingTask: Task<Void, Error>?

    init(userManager: UserManager, userId: Int? = nil) {
        self.userManager = userManager
        self.userId = userId
    }
    
    func loadUser() async throws {
        avatarId = UUID()
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
            pausePlayingComposition()
            compositions = try await userManager.loadUserCompositions(userId: userId)
            compositionStates = .init(repeating: .paused, count: compositions?.count ?? 0)
        }
    }
    
    
    func onEditButtonPressed() {
        let editProfileViewModel = EditProfileViewModel(userManager: userManager, onSuccess: { [weak self] _ in
            self?.loadUser()
        })
        let editProfileViewController = EditProfileViewController(viewModel: editProfileViewModel)
        editProfileViewModel.viewController = editProfileViewController
        viewController?.present(UINavigationController(rootViewController: editProfileViewController), animated: true)
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

    func compositionTapped(atIndex index: Int) {
        guard let compositionId = compositions?[index].id else { return }

        Task {
            await MainActor.run {
                viewController?.startLoader()
            }

            let composition = try await compositionManager.getComposition(id: compositionId)
            let compositionScreen = try await CompositionScreen(composition: composition)

            await MainActor.run {
                viewController?.stopLoader()
                viewController?.present(compositionScreen.getViewController(), animated: true)
            }
        }
    }

    func compositionPlayButtonTapped(atIndex index: Int) {
        if playingCompositionIndex == index {
            pausePlayingComposition()
        } else if let composition = compositions?[index] {
            pausePlayingComposition()
            playingCompositionIndex = index
            compositionStates[index] = .loading
            compositionPreviewLoadingTask = Task {
                let composition = try await compositionManager.getComposition(id: composition.id)
                compositionPreviewManager = try await .init(composition: composition)
                compositionPreviewManager?.play()
                compositionStates[index] = .playing
            }
        }
    }

    func compositionFavouriteButtonTapped(atIndex index: Int) {
        guard let composition = compositions?[index] else { return }

        if composition.isFavourite {
            compositions?[index] = .init(id: composition.id, name: composition.name, isFavourite: false)
            Task {
                try await favouritesManager.removeCompositionFromFavourite(compositionId: composition.id)
            }
        } else {
            compositions?[index] = .init(id: composition.id, name: composition.name, isFavourite: true)
            Task {
                try await favouritesManager.addCompositionToFavourite(compositonId: composition.id)
            }
        }
    }

    private func pausePlayingComposition() {
        if let playingCompositionIndex = playingCompositionIndex {
            self.playingCompositionIndex = 0
            compositionPreviewLoadingTask?.cancel()
            compositionPreviewLoadingTask = nil
            compositionPreviewManager = nil
            compositionStates[playingCompositionIndex] = .paused
        }
    }
}
