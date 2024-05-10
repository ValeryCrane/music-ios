import Foundation

class MutableSample {
    let sampleId: Int
    var name: String
    var isMuted: Bool
    var effects: MutableEffects

    init(_ sample: Sample) {
        self.sampleId = sample.sampleId
        self.name = sample.name
        self.isMuted = sample.isMuted
        self.effects = .init(effects: sample.effects)
    }
}
