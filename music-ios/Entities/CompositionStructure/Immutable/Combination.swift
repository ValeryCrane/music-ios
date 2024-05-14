import Foundation

struct Combination: Codable {
    let name: String
    let effects: [EffectType: [EffectPropertyType: Float]]
    let melodies: [Melody]
    let samples: [Sample]
}

extension Combination {
    static func empty(withName name: String) -> Combination {
        .init(name: name, effects: [:], melodies: [], samples: [])
    }
}

extension Combination {
    init(_ mutableCombination: MutableCombination) {
        self.init(
            name: mutableCombination.name,
            effects: mutableCombination.effects.value,
            melodies: mutableCombination.melodies.map { .init($0) },
            samples: mutableCombination.samples.map { .init($0) }
        )
    }
}
