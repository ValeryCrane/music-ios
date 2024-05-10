import Foundation

class MutableMelody {
    var name: String
    var keyboardId: Int
    var isMuted: Bool
    var isPedalActive: Bool
    var effects: MutableEffects
    var measures: Int
    var notes: [MutableNote]

    init(_ melody: Melody) {
        self.name = melody.name
        self.keyboardId = melody.keyboardId
        self.isMuted = melody.isMuted
        self.isPedalActive = melody.isPedalActive
        self.effects = .init(effects: melody.effects)
        self.measures = melody.measures
        self.notes = melody.notes.map { .init($0) }
    }
}
