import Foundation

struct CompositionMiniatureResponse: Decodable {
    let id: Int
    let name: String
    let isFavourite: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case isFavourite = "is_favourite"
    }
}
