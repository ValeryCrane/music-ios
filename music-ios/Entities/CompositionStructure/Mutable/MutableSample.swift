import Foundation

struct MutableSample {
    let sampleId: Int
    var name: String
    var effects: [MutableEffect]
    
    init(_ sample: Sample) {
        self.sampleId = sample.sampleId
        self.name = sample.name
        self.effects = sample.effects.map { .init($0) }
    }
}
