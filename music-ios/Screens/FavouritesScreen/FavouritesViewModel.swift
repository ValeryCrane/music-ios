import Foundation
import UIKit

@MainActor
final class FavouritesViewModel: ObservableObject {
    
    @Published
    var currentGroup: SearchGroup = .compositions
    
    @Published
    var favouriteCompositions: [CompositionMiniature]? = nil

    @Published
    var compositionStates: [CompositionMiniatureView.PlayState] = []

    @Published
    var favouriteUsers: [User]? = nil

    weak var viewController: UIViewController?

    private let favouritesManager: FavouritesManager
    private let compositionManager = CompositionManager()

    private var playingCompositionIndex: Int?
    private var compositionPreviewManager: CompositionPreviewManager?
    private var compositionPreviewLoadingTask: Task<Void, Error>?

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
                pausePlayingComposition()
                favouriteCompositions = try await favouritesManager.getFavouriteCompositions()
                compositionStates = .init(repeating: .paused, count: favouriteCompositions?.count ?? 0)
            case .users:
                favouriteUsers = try await favouritesManager.getFavouriteUsers()
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }

    func compositionTapped(atIndex index: Int) {
        guard let compositionId = favouriteCompositions?[index].id else { return }

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
        } else if let composition = favouriteCompositions?[index] {
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
        guard let composition = favouriteCompositions?[index] else { return }

        if composition.isFavourite {
            favouriteCompositions?[index] = .init(id: composition.id, name: composition.name, isFavourite: false)
            Task {
                try await favouritesManager.removeCompositionFromFavourite(compositionId: composition.id)
            }
        } else {
            favouriteCompositions?[index] = .init(id: composition.id, name: composition.name, isFavourite: true)
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
