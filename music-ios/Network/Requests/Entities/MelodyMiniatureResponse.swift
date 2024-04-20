import Foundation

struct MelodyMiniatureResponse: Decodable {
    let id: Int
    let keyboardId: Int
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case keyboardId = "keyboard_id"
        case name
    }
}
