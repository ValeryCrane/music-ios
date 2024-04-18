import Foundation

final class FavouritesManager {
    
    private let favouriteCompositionsGet = Requests.FavouriteCompositionsGet()
    private let favouriteCompositionAdd = Requests.FavouriteCompositionAdd()
    private let favouriteCompositionRemove = Requests.FavouriteCompositionRemove()
    
    private let favouriteUsersGet = Requests.FavouriteUsersGet()
    private let favouriteUserAdd = Requests.FavouriteUserAdd()
    private let favouriteUserRemove = Requests.FavouriteUserRemove()
    
    func addCompositionToFavourite(compositonId: Int) async throws {
        try await favouriteCompositionAdd.run(with: .init(id: compositonId))
    }
    
    func removeCompositionFromFavourite(compositionId: Int) async throws {
        try await favouriteCompositionRemove.run(with: .init(id: compositionId))
    }
    
    func getFavouriteCompositions() async throws -> [CompositionMiniature] {
        let favouriteCompositionsGetResponse = try await favouriteCompositionsGet.run(with: .init())
        return favouriteCompositionsGetResponse.compositions.map({ .init(from: $0) })
    }
    
    func addUserToFavourite(userId: Int) async throws {
        try await favouriteUserAdd.run(with: .init(id: userId))
    }
    
    func removeUserFromFavourite(userId: Int) async throws {
        try await favouriteUserRemove.run(with: .init(id: userId))
    }
    
    func getFavouriteUsers() async throws -> [User] {
        let favouriteUsersGetResponse = try await favouriteUsersGet.run(with: .init())
        return favouriteUsersGetResponse.users.map({ .init(from: $0) })
    }
}
