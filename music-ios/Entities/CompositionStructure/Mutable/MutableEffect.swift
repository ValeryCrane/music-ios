import Foundation

class MutableEffect {
    let type: EffectType
    var properties: [MutableEffectProperty]
    
    init(_ effect: Effect) {
        self.type = effect.type
        self.properties = effect.properties.map { .init($0) }
    }
}
