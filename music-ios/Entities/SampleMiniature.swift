import Foundation

struct SampleMiniature {
    let id: Int
    let name: String
}

extension SampleMiniature {
    init(from sampleMiniatureResponse: SampleMiniatureResponse) {
        self.id = sampleMiniatureResponse.id
        self.name = sampleMiniatureResponse.name
    }
}
