import Foundation

struct Melody {
    let name: String
    let keyboardId: Int
    let isMuted: Bool
    let isPedalActive: Bool
    let effects: [EffectType: [EffectPropertyType: Float]]
    let measures: Int
    let notes: [Note]
}
