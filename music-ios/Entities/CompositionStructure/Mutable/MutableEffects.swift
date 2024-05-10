import Foundation

class MutableEffects {
    var value: [EffectType: [EffectPropertyType: Float]]

    init(effects: [EffectType : [EffectPropertyType : Float]]) {
        self.value = effects
    }
}
