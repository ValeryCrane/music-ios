import Foundation

class MutableComposition {
    let id: Int
    var name: String
    var isFavourite: Bool
    var visibility: CompositionVisibility
    var creator: User
    var editors: [User]
    
    var bpm: Int
    var combinations: [MutableCombination]
    
    init(_ composition: Composition) {
        self.id = composition.id
        self.name = composition.name
        self.isFavourite = composition.isFavourite
        self.visibility = composition.visibility
        self.creator = composition.creator
        self.editors = composition.editors
        
        self.bpm = composition.bpm
        self.combinations = composition.combinations.map { .init($0) }
    }
}
