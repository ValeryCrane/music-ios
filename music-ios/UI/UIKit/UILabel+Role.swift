import Foundation
import UIKit

extension UILabel {
    enum Role {
        case title
        case primary
        case secondary
        
        var fontSize: CGFloat {
            switch self {
            case .title:
                18
            case .primary:
                14
            case .secondary:
                14
            }
        }
        
        var fontWeight: UIFont.Weight {
            switch self {
            case .title:
                .bold
            case .primary:
                .regular
            case .secondary:
                .regular
            }
        }
    }
    
    func role(_ role: Role) {
        font = .systemFont(ofSize: role.fontSize, weight: role.fontWeight)
    }
}
