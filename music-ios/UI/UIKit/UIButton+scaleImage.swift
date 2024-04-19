import Foundation
import UIKit

extension UIButton {
    func scaleImage(toWidth width: CGFloat) {
        if let targetSize = imageView?.image?.size.scaled(toWidth: width) {
            fixSize(targetSize)
        }
    }
    
    func scaleImage(toHeight height: CGFloat) {
        if let targetSize = imageView?.image?.size.scaled(toHeight: height) {
            fixSize(targetSize)
        }
    }
    
    private func fixSize(_ size: CGSize) {
        contentVerticalAlignment = .fill
        contentHorizontalAlignment = .fill
        
        translatesAutoresizingMaskIntoConstraints = false
        removeConstraints(constraints)
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
    }
}
