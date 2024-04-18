import Foundation
import UIKit
import SwiftUI

final class SearchViewController: UIHostingController<SearchView> {
    
    private let viewModel: SearchViewModel
    
    private let searchController = UISearchController()
    
    init(searchManager: SearchManager) {
        let viewModel = SearchViewModel(searchManager: searchManager)
        let rootView = SearchView(viewModel: viewModel)
        self.viewModel = viewModel
        
        super.init(rootView: rootView)
        
        title = "Поиск"
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchQuery = searchController.searchBar.text ?? ""
        viewModel.updateSearchResults()
    }
}
