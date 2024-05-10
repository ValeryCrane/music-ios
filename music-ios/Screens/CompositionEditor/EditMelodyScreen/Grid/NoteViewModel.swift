import Foundation

final class NoteViewModel {
    var key: Int
    var start: Double
    var end: Double
    
    init(key: Int, start: Double, end: Double) {
        self.key = key
        self.start = start
        self.end = end
    }
}
