import Foundation

class MutableMelody {
    var name: String
    var keyboardId: Int
    var isMuted: Bool
    var resolution: Int
    var effects: [MutableEffect]
    var keys: [Int?]

    init(_ melody: Melody) {
        self.name = melody.name
        self.keyboardId = melody.keyboardId
        self.isMuted = melody.isMuted
        self.resolution = melody.resolution
        self.effects = melody.effects.map { .init($0) }
        self.keys = melody.keys
    }
}
