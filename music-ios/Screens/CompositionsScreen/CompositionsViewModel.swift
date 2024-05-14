import Foundation
import UIKit

@MainActor
final class CompositionsViewModel: ObservableObject {
    
    @Published
    var compositions: [CompositionMiniature]? = nil
    
    weak var viewController: UIViewController?
    
    private let compositionManager: CompositionManager
    
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
            compositions = try await compositionManager.getCompositions()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func onCreateComposition(name: String) {
        Task {
            viewController?.startLoader()
            let composition = try await compositionManager.createComposition(name: name)
            let compositionScreen = try await CompositionScreen(composition: composition)
            viewController?.stopLoader()

            viewController?.present(compositionScreen.getViewController(), animated: true)
        }
    }

    func onOpenComposition(id: Int) {
        Task {
            viewController?.startLoader()
            let composition = try await compositionManager.getComposition(id: id)
            let compositionScreen = try await CompositionScreen(composition: composition)
            viewController?.stopLoader()

            viewController?.present(compositionScreen.getViewController(), animated: true)
        }
    }
}
