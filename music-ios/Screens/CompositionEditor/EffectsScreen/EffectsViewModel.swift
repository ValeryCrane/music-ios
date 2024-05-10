import Foundation
import UIKit

protocol EffectsViewModelInput {
    func getValueOfPropertyType(_ propertyType: EffectPropertyType) -> Float
    func setValue(_ value: Float, ofPropertyType propertyType: EffectPropertyType)
}

final class EffectsViewModel {

    private let effectsManager: EffectsManager

    init(effectsManager: EffectsManager) {
        self.effectsManager = effectsManager
    }
}

extension EffectsViewModel: EffectsViewModelInput {
    func setValue(_ value: Float, ofPropertyType propertyType: EffectPropertyType) {
        effectsManager.update(effectPropertyType: propertyType, value: value)
    }
    
    func getValueOfPropertyType(_ propertyType: EffectPropertyType) -> Float {
        effectsManager.getValueOfPropertyType(propertyType)
    }
}


