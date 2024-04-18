import Foundation

@MainActor
final class FavouritesViewModel: ObservableObject {
    
    @Published
    var favouriteCompositions: [CompositionMiniature]? = nil
    
    @Published
    var favouriteUsers: [User]? = nil
    
    private let favouritesManager: FavouritesManager
    
    init(favouritesManager: FavouritesManager) {
        self.favouritesManager = favouritesManager
    }
    
    func loadCompositions() {
        Task {
            await updateCompositions()
        }
    }
    
    func updateCompositions() async {
        do {
            favouriteCompositions = try await favouritesManager.getFavouriteCompositions()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadUsers() {
        Task {
            await updateUsers()
        }
    }
    
    func updateUsers() async {
        do {
            favouriteUsers = try await favouritesManager.getFavouriteUsers()
        } catch {
            print(error.localizedDescription)
        }
    }
}
