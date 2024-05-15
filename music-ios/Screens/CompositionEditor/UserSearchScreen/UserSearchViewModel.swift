import Foundation
import UIKit

protocol UserSearchViewModelInput {
    func getUsers() -> [User]?
    func getIsUsersFullyLoaded() -> Bool
    func search(query: String?)
    func loadMoreResults()
    func userChosen(atIndex index: Int)
    func cancelButtonTapped()
}

protocol UserSearchViewModelOutput: UIViewController {
    func updateResults()
}

final class UserSearchViewModel {
    weak var view: UserSearchViewModelOutput?

    private let ignoredUserIds: Set<Int>
    private let searchUsers = Requests.SearchUsers()
    private let chooseUserHandler: (User) async -> Void

    private var query = ""
    private var users: [User]? = nil
    private var nextPage = 1
    private var isFullyLoaded = false
    private var loadingTask: Task<Void, Error>?

    init(ignoredUserIds: Set<Int>, chooseUserHandler: @escaping (User) async -> Void) {
        self.ignoredUserIds = ignoredUserIds
        self.chooseUserHandler = chooseUserHandler
    }

    private func loadNextPage() async throws {
        guard !isFullyLoaded else { return }

        let searchResults = try await searchUsers.run(with: .init(
            query: self.query, page: self.nextPage
        ))

        if searchResults.totalPages > searchResults.page {
            nextPage += 1
        } else {
            isFullyLoaded = true
        }

        let filteredUsers = searchResults.users
            .map({ User(from: $0) })
            .filter({ !ignoredUserIds.contains($0.id) })

        users = users ?? []
        users?.append(contentsOf: filteredUsers)

        await MainActor.run {
            view?.updateResults()
        }
    }
}

extension UserSearchViewModel: UserSearchViewModelInput {
    func getUsers() -> [User]? {
        users
    }

    func getIsUsersFullyLoaded() -> Bool {
        isFullyLoaded
    }

    func search(query: String?) {
        guard query != self.query else { return }

        loadingTask?.cancel()
        loadingTask = nil

        self.query = query ?? ""
        self.users = nil
        self.nextPage = 1
        self.isFullyLoaded = false
        view?.updateResults()

        loadingTask = Task {
            try await loadNextPage()
            loadingTask = nil
        }
    }

    func loadMoreResults() {
        if !isFullyLoaded, loadingTask == nil {
            loadingTask = Task {
                try await loadNextPage()
                loadingTask = nil
            }
        }
    }

    func userChosen(atIndex index: Int) {
        view?.startLoader()
        Task {
            if let user = users?[index] {
                await chooseUserHandler(user)
            }
            
            await MainActor.run {
                view?.stopLoader()
                view?.dismiss(animated: true)
            }
        }
    }
    
    func cancelButtonTapped() {
        view?.dismiss(animated: true)
    }
}
