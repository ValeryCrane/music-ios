import Foundation
import UIKit

@MainActor
final class CompositionsViewModel: ObservableObject {
    
    @Published
    var compositions: [CompositionMiniature]? = nil

    @Published
    var compositionStates: [CompositionMiniatureView.PlayState] = []

    weak var viewController: UIViewController?
    
    private let compositionManager: CompositionManager

    private let favouritesManager = FavouritesManager()

    private var playingCompositionIndex: Int?
    private var compositionPreviewManager: CompositionPreviewManager?
    private var compositionPreviewLoadingTask: Task<Void, Error>?

    init(compositionManager: CompositionManager) {
        self.compositionManager = compositionManager
    }
    
    func loadCompositions() {
        Task {
            await updateCompositions()
        }
    }
    
    func updateCompositions() async {
        do {
            pausePlayingComposition()
            compositions = try await compositionManager.getCompositions()
            compositionStates = .init(repeating: .paused, count: compositions?.count ?? 0)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func onCreateComposition(name: String) {
        pausePlayingComposition()
        viewController?.startLoader()
        Task {
            let composition = try await compositionManager.createComposition(name: name)
            let compositionScreen = try await CompositionScreen(composition: composition)

            await MainActor.run {
                viewController?.stopLoader()
                viewController?.present(compositionScreen.getViewController(), animated: true)
            }
        }
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
