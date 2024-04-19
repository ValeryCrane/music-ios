import Foundation

class MutableEffect {
    let type: EffectType
    var value: Float
    
    init(_ effect: Effect) {
        self.type = effect.type
        self.value = effect.value
    }
}
