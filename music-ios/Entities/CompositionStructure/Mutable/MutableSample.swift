import Foundation

class MutableSample {
    let sampleId: Int
    var name: String
    var isMuted: Bool
    var beats: Int
    var effects: MutableEffects

    init(_ sample: Sample) {
        self.sampleId = sample.sampleId
        self.name = sample.name
        self.isMuted = false
        self.beats = sample.beats
        self.effects = .init(effects: sample.effects)
    }
}
