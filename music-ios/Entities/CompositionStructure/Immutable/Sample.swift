import Foundation

struct Sample {
    let sampleId: Int
    let name: String
    let isMuted: Bool
    let effects: [EffectType: [EffectPropertyType: Float]]
}
