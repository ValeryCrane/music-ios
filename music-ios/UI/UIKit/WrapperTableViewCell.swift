import Foundation
import UIKit

class WrapperTableViewCell: UITableViewCell {

    let wrapperView = UIView()

    lazy var topConstraint = wrapperView.topAnchor.constraint(equalTo: contentView.topAnchor)
    lazy var leadingConstraint = wrapperView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
    lazy var trailingConstraint  = wrapperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    lazy var bottomConstraint = wrapperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)

    var insets: UIEdgeInsets = .zero {
        didSet {
            topConstraint.constant = insets.top
            leadingConstraint.constant = insets.left
            trailingConstraint.constant = -insets.right
            bottomConstraint.constant = -insets.bottom
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        wrapperView.backgroundColor = .imp.lightGray
        wrapperView.layer.cornerRadius = .defaultCornerRadius

        contentView.addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topConstraint, leadingConstraint, trailingConstraint, bottomConstraint
        ])
    }
}
