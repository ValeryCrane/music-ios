import Foundation

struct BlueprintResponse: Decodable {
    let id: Int
    let parentId: Int?
    let creator: UserResponse
    let value: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parent_id"
        case creator
        case value
    }
}
