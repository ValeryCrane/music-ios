import Foundation

@MainActor
final class FavouritesViewModel: ObservableObject {
    
    @Published
    var currentGroup: SearchGroup = .compositions
    
    @Published
    var favouriteCompositions: [CompositionMiniature]? = nil
    
    @Published
    var favouriteUsers: [User]? = nil
    
    private let favouritesManager: FavouritesManager
    
    init(favouritesManager: FavouritesManager) {
        self.favouritesManager = favouritesManager
    }
    
    func loadCurrentGroup() {
        Task {
            await updateCurrentGroup()
        }
    }
    
    func updateCurrentGroup() async {
        do {
            switch currentGroup {
            case .compositions:
                favouriteCompositions = try await favouritesManager.getFavouriteCompositions()
            case .users:
                favouriteUsers = try await favouritesManager.getFavouriteUsers()
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
