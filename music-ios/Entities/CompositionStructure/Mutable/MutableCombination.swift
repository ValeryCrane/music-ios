import Foundation

class MutableCombination {
    var name: String
    var effects: [MutableEffect]
    var melodies: [MutableMelody]
    var samples: [MutableSample]
    
    init(_ combination: Combination) {
        self.name = combination.name
        self.effects = combination.effects.map { .init($0) }
        self.melodies = combination.melodies.map { .init($0) }
        self.samples = combination.samples.map { .init($0) }
    }
}


