import Foundation

final class SearchManager {
    private let searchUsers = Requests.SearchUsers()
    private let searchCompositions = Requests.SearchCompositions()
    
    func searchUsers(query: String, page: Int) async throws -> (users: [User], isLastPage: Bool) {
        let searchUsersResponse = try await searchUsers.run(with: .init(query: query, page: page))
        let users: [User] = searchUsersResponse.users.map({ .init(from: $0) })
        return (
            users: users,
            isLastPage: searchUsersResponse.totalPages == searchUsersResponse.page
        )
    }
    
    func searchCompositions(query: String, page: Int) async throws -> (compositions: [CompositionMiniature], isLastPage: Bool) {
        let searchCompositionsResponse = try await searchCompositions.run(with: .init(query: query, page: page))
        let compositions: [CompositionMiniature] = searchCompositionsResponse.compositions.map({ .init(from: $0) })
        return (
            compositions: compositions,
            isLastPage: searchCompositionsResponse.totalPages == searchCompositionsResponse.page
        )
    }
}
