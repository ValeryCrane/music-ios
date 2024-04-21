import Foundation
import UIKit

extension MelodyKeyCollectionViewCell {
    private enum Constants {
        static let verticalOffsets: CGFloat = 8
        static let horizontalOffsets: CGFloat = 8
    }
}

final class MelodyKeyCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "MelodyKeyCollectionViewCell"
    
    private let keyView = UIView()
    
    override var isSelected: Bool {
        didSet {
            keyView.backgroundColor = isSelected ? .imp.complementary : .white
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.backgroundColor = .imp.lightGray
        keyView.backgroundColor = isSelected ? .imp.complementary : .white
        keyView.layer.cornerRadius = .defaultCornerRadius
    }
    
    private func layout() {
        contentView.addSubview(keyView)
        keyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalOffsets),
            keyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalOffsets),
            keyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalOffsets),
            keyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalOffsets)
        ])
    }
}
