import Foundation
import UIKit

extension RecordSampleButton {
    private enum Constants {
        static let buttonSize: CGFloat = 64
        static let verticalOffsets: CGFloat = 16
        static let horizontalOffests: CGFloat = 16
    }
}

final class RecordSampleButton: UIControl {
    
    private let imageView = UIImageView()
    
    init(icon: UIImage?, foregroundColor: UIColor, backgroundColor: UIColor) {
        super.init(frame: .zero)
        
        configure(icon: icon, foregroundColor: foregroundColor, backgroundColor: backgroundColor)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(icon: UIImage?, foregroundColor: UIColor, backgroundColor: UIColor) {
        imageView.image = icon
        imageView.tintColor = foregroundColor
        imageView.contentMode = .scaleAspectFit
        self.backgroundColor = backgroundColor
        layer.cornerRadius = .defaultCornerRadius
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(buttonPressed(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func layout() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalOffsets),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalOffests),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalOffests),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalOffsets),
            
            heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            widthAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])
    }
    
    @objc
    private func buttonPressed(_ sender: UITapGestureRecognizer) {
        sendActions(for: .touchUpInside)
    }
}
