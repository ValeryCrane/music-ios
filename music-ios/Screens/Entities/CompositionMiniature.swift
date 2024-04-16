import Foundation

struct CompositionMiniature {
    let id: Int
    let name: String
    let isFavourite: Bool
}

extension CompositionMiniature {
    init(from compositionMiniatureResponse: CompositionMiniatureResponse) {
        self.init(
            id: compositionMiniatureResponse.id,
            name: compositionMiniatureResponse.name,
            isFavourite: compositionMiniatureResponse.isFavourite
        )
    }
}
