import Foundation

final class CompositionManager {
    
    private let compositionsGet = Requests.CompositionsGet()
    private let compositionCreate = Requests.CompositionCreate()
    
    func getCompositions() async throws -> [CompositionMiniature] {
        let compositionsGetResponse = try await compositionsGet.run(with: .init())
        return compositionsGetResponse.compositions.map({ .init(from: $0) })
    }
    
    func createComposition(name: String) async throws {
        try await compositionCreate.run(with: .init(name: name))
    }
}
