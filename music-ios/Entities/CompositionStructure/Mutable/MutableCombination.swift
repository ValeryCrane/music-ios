import Foundation

class MutableCombination {
    var name: String
    var isMuted: Bool
    var effects: MutableEffects
    var melodies: [MutableMelody]
    var samples: [MutableSample]
    
    init(_ combination: Combination) {
        self.name = combination.name
        self.isMuted = true
        self.effects = .init(effects: combination.effects)
        self.melodies = combination.melodies.map { .init($0) }
        self.samples = combination.samples.map { .init($0) }
    }
}


