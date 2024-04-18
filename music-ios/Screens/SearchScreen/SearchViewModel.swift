import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    
    @Published
    var currentGroup: SearchGroup = .compositions
    
    @Published
    var searchQuery: String = ""
    
    @Published
    var isFullyLoaded: Bool = false
    
    @Published
    var userResults: [User]? = nil
    
    @Published
    var compositionResults: [CompositionMiniature]? = nil
    
    private let searchManager: SearchManager
    
    private var usersPage = 1
    private var compositionsPage = 1
    private var isUsersFullyLoaded = false
    private var isCompositionsFullyLoaded = false
    
    init(searchManager: SearchManager) {
        self.searchManager = searchManager
    }
    
    func updateSearchResults() {
        Task {
            await updateSearchResults()
        }
    }
    
    func updateSearchResults() async {
        clearResults()
        do {
            switch currentGroup {
            case .compositions:
                let searchCompositionsResult = try await searchManager.searchCompositions(
                    query: searchQuery,
                    page: compositionsPage
                )
                compositionsPage += 1
                isCompositionsFullyLoaded = searchCompositionsResult.isLastPage
                compositionResults = searchCompositionsResult.compositions
            case .users:
                let searchUsersResult = try await searchManager.searchUsers(
                    query: searchQuery,
                    page: usersPage
                )
                usersPage += 1
                isUsersFullyLoaded = searchUsersResult.isLastPage
                userResults = searchUsersResult.users
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadNextPage() {
        switch currentGroup {
        case .compositions:
            guard !isCompositionsFullyLoaded else { return }
            
            Task {
                let searchCompositionsResult = try await searchManager.searchCompositions(
                    query: searchQuery,
                    page: compositionsPage
                )
                compositionsPage += 1
                isCompositionsFullyLoaded = searchCompositionsResult.isLastPage
                compositionResults?.append(contentsOf: searchCompositionsResult.compositions)
            }
        case .users:
            guard !isUsersFullyLoaded else { return }
            
            Task {
                let searchUsersResult = try await searchManager.searchUsers(
                    query: searchQuery,
                    page: usersPage
                )
                usersPage += 1
                isUsersFullyLoaded = searchUsersResult.isLastPage
                userResults?.append(contentsOf: searchUsersResult.users)
            }
        }
    }
    
    private func clearResults() {
        userResults = nil
        compositionResults = nil
        usersPage = 1
        compositionsPage = 1
        isUsersFullyLoaded = false
        isCompositionsFullyLoaded = false
    }
}
