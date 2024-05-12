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
