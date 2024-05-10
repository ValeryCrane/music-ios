import Foundation

struct KeyboardMiniature {
    let id: Int
    let name: String
    let numberOfKeys: Int
}

extension KeyboardMiniature {
    init(from keyboardMiniatureResponse: KeyboardMiniatureResponse) {
        self.init(
            id: keyboardMiniatureResponse.id,
            name: keyboardMiniatureResponse.name,
            numberOfKeys: keyboardMiniatureResponse.numberOfKeys
        )
    }
}
