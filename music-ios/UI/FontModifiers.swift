import Foundation
import SwiftUI

extension View {
    func titleFont() -> some View {
        self.font(.system(size: 18, weight: .bold))
    }
    
    func primaryFont() -> some View {
        self.font(.system(size: 14))
    }
    
    func secondaryFont() -> some View {
        self.foregroundStyle(.secondary).font(.system(size: 14))
    }
}
