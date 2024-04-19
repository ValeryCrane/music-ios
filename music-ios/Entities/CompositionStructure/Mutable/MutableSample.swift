import Foundation

class MutableSample {
    let sampleId: Int
    var name: String
    var isMuted: Bool
    var effects: [MutableEffect]
    
    init(_ sample: Sample) {
        self.sampleId = sample.sampleId
        self.name = sample.name
        self.isMuted = sample.isMuted
        self.effects = sample.effects.map { .init($0) }
    }
}
