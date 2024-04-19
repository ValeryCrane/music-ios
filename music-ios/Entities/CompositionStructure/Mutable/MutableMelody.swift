import Foundation

struct MutableMelody {
    var name: String
    var keyboardId: Int
    var effects: [MutableEffect]
    var sampleIds: [Int?]

    init(_ melody: Melody) {
        self.name = melody.name
        self.keyboardId = melody.keyboardId
        self.effects = melody.effects.map { .init($0) }
        self.sampleIds = melody.sampleIds
    }
}
