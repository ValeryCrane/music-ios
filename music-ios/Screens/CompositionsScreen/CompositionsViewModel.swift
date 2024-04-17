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
            try await compositionManager.createComposition(name: name)
            viewController?.stopLoader()
        }
    }

}
