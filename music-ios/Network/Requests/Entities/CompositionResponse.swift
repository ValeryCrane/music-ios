import Foundation

struct CompositionResponse: Decodable {
    let id: Int
    let name: String
    let isFavourite: Bool
    let visibility: CompositionVisibility
    let creator: UserResponse
    let editors: [UserResponse]
    let blueprint: BlueprintResponse
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case isFavourite = "isFavourite"
        case visibility
        case creator
        case editors
        case blueprint
    }
    
}
