import Foundation

struct KeyboardMiniatureResponse: Decodable {
    let id: Int
    let name: String
    let numberOfKeys: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case numberOfKeys = "number_of_keys"
    }
}
