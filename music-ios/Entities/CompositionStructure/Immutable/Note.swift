import Foundation

struct Note: Codable {
    let keyNumber: Int
    let start: Double
    let end: Double

    private enum CodingKeys: String, CodingKey {
        case keyNumber = "key_number"
        case start
        case end
    }
}

extension Note {
    init(_ mutableNote: MutableNote) {
        self.init(
            keyNumber: mutableNote.keyNumber,
            start: mutableNote.start,
            end: mutableNote.end
        )
    }
}
