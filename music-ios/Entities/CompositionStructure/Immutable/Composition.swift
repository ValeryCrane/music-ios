import Foundation

struct Composition {
    let id: Int
    let name: String
    let isFavourite: Bool
    let visibility: CompositionVisibility
    let creator: User
    let editors: [User]
    
    let bpm: Int
    let combinations: [Combination]
}
