import Foundation

class MutableEffectProperty {
    let type: EffectPropertyType
    var value: Float
    
    init(_ effectProperty: EffectProperty) {
        self.type = effectProperty.type
        self.value = effectProperty.value
    }
}
