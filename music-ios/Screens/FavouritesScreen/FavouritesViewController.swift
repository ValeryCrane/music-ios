import Foundation
import UIKit
import SwiftUI

final class FavouritesViewController: UIHostingController<FavouritesView> {
    
    init(favouritesManager: FavouritesManager) {
        let viewModel = FavouritesViewModel(favouritesManager: favouritesManager)
        let rootView = FavouritesView(viewModel: viewModel)
        
        super.init(rootView: rootView)
        
        title = "Избранное"
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
