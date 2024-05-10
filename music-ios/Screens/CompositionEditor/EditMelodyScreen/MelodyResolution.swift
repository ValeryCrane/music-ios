import Foundation
import UIKit

enum MelodyResolution: CaseIterable {
    case standart
    case detailed
    case triad
    case detailedTriad
    
    var title: String {
        switch self {
        case .standart:
            "Стандарт"
        case .detailed:
            "Расширенный"
        case .triad:
            "Триоли"
        case .detailedTriad:
            "Расширенные триоли"
        }
    }
    
    var image: UIImage {
        fractionTitle.image(font: .systemFont(ofSize: 16))
    }
    
    var fractionTitle: String {
        switch self {
        case .standart:
            "¹⁄₁₆"
        case .detailed:
            "¹⁄₃₂"
        case .triad:
            "¹⁄₁₂"
        case .detailedTriad:
            "¹⁄₂₄"
        }
    }

    var notesInBeat: Int {
        switch self {
        case .standart:
            4
        case .detailed:
            8
        case .triad:
            3
        case .detailedTriad:
            6
        }
    }
}
