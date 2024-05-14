import Foundation

final class CompositionManager {
    
    private let compositionGet = Requests.CompositionGet()
    private let compositionsGet = Requests.CompositionsGet()
    private let compositionCreate = Requests.CompositionCreate()

    func getComposition(id: Int) async throws -> Composition {
        let compositionResponse = try await compositionGet.run(with: .init(id: id))
        let composition = try Composition(from: compositionResponse)
        return composition
    }

    func getCompositions() async throws -> [CompositionMiniature] {
        let compositionsGetResponse = try await compositionsGet.run(with: .init())
        return compositionsGetResponse.compositions.map({ .init(from: $0) })
    }
    
    func createComposition(name: String) async throws -> Composition {
        let compositionResponse = try await compositionCreate.run(with: .init(name: name))
        let composition = try Composition(from: compositionResponse)
        return composition
    }
}
