import Foundation

struct Sample: Codable {
    let sampleId: Int
    let name: String
    let beats: Int
    let effects: [EffectType: [EffectPropertyType: Float]]
}

extension Sample {
    init(_ mutableSample: MutableSample) {
        self.init(
            sampleId: mutableSample.sampleId,
            name: mutableSample.name,
            beats: mutableSample.beats,
            effects: mutableSample.effects.value
        )
    }
}
