import Foundation

struct Melody {
    let name: String
    let keyboardId: Int
    let isMuted: Bool
    let resolution: Int
    let effects: [Effect]
    let keys: [Int?]
}
