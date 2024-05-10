import Foundation

class MutableNote {
    var keyNumber: Int
    var start: Double
    var end: Double
    
    init(_ note: Note) {
        self.keyNumber = note.keyNumber
        self.start = note.start
        self.end = note.end
    }
}
