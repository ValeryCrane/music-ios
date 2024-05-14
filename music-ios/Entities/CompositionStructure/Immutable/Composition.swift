import Foundation

struct Composition {
    let id: Int
    let name: String
    let isFavourite: Bool
    let visibility: CompositionVisibility
    let creator: User
    let editors: [User]
    
    let bpm: Int
    let combinations: [Combination]
}

extension Composition {
    private struct Blueprint: Codable {
        let bpm: Int
        let combinations: [Combination]
    }

    init(from compositionResponse: CompositionResponse) throws {
        self.id = compositionResponse.id
        self.name = compositionResponse.name
        self.isFavourite = compositionResponse.isFavourite
        self.visibility = compositionResponse.visibility
        self.creator = .init(from: compositionResponse.creator)
        self.editors = compositionResponse.editors.map { .init(from: $0) }

        guard 
            let blueprintData = compositionResponse.blueprint.value.data(using: .utf8, allowLossyConversion: false),
            let blueprint = try? JSONDecoder().decode(Blueprint.self, from: blueprintData)
        else {
            throw RuntimeError("Не удалось расшифровать макет композиции")
        }

        self.bpm = blueprint.bpm
        self.combinations = blueprint.combinations
    }

    func compositionBlueprintEditParameters() throws -> Requests.CompositionBlueprintEdit.Parameters {
        let blueprint = Blueprint(bpm: bpm, combinations: combinations)
        if
            let blueprintData = try? JSONEncoder().encode(blueprint),
            let blueprintString = String(data: blueprintData, encoding: .utf8)
        {
            return .init(id: id, blueprint: blueprintString)
        } else {
            throw RuntimeError("Не удалось сериализовать макет композиции")
        }
    }
}

extension Composition {
    init(_ mutableComposition: MutableComposition) {
        self.init(
            id: mutableComposition.id,
            name: mutableComposition.name,
            isFavourite: mutableComposition.isFavourite,
            visibility: mutableComposition.visibility,
            creator: mutableComposition.creator,
            editors: mutableComposition.editors,
            bpm: mutableComposition.bpm,
            combinations: mutableComposition.combinations.map { .init($0) }
        )
    }
}
