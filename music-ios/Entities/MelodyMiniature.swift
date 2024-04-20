import Foundation

struct MelodyMiniature {
    let id: Int
    let keyboardId: Int
    let name: String
}

extension MelodyMiniature {
    init(from melodyMiniatureResponse: MelodyMiniatureResponse) {
        self.id = melodyMiniatureResponse.id
        self.name = melodyMiniatureResponse.name
        self.keyboardId = melodyMiniatureResponse.keyboardId
    }
}
