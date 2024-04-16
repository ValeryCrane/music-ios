import Foundation
import SwiftUI

extension NiceButton {
    enum Role {
        case primary
        case secondary
        
        var foregroundColor: UIColor {
            switch self {
            case .primary: return .white
            case .secondary: return .imp.primary
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .primary: return .imp.primary
            case .secondary: return .clear
            }
        }
        
        var verticalPadding: CGFloat {
            switch self {
            case .primary: return 12
            case .secondary: return 8
            }
        }
    }
}

struct NiceButton: View {
    private let role: Role
    private let title: String
    private let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .primaryFont()
                .foregroundStyle(Color(uiColor: role.foregroundColor))
                .padding(.vertical, role.verticalPadding)
                .frame(maxWidth: 256)
                .background(Color(uiColor: role.backgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    init(_ title: String, role: Role, action: @escaping () -> Void) {
        self.role = role
        self.title = title
        self.action = action
    }
}
