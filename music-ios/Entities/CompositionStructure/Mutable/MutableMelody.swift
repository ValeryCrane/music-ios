import Foundation

class MutableMelody {
    var name: String
    var keyboardId: Int
    var isMuted: Bool
    var effects: [MutableEffect]
    var sampleIds: [Int?]

    init(_ melody: Melody) {
        self.name = melody.name
        self.keyboardId = melody.keyboardId
        self.isMuted = melody.isMuted
        self.effects = melody.effects.map { .init($0) }
        self.sampleIds = melody.sampleIds
    }
}
