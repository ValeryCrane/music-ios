import UIKit

extension ChatTableViewCell {
    private enum Constants {
        static let horisontalOffsets: CGFloat = 16
        static let verticalOffests: CGFloat = 4
        static let labelInsets: CGFloat = 8
        static let labelSpacing: CGFloat = 2
    }
}

final class ChatTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ChatTableViewCell"

    private let wrapperView = UIView()
    private let usernameLabel = UILabel()
    private let messageLabel = UILabel()

    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?

    private var usernameConstraint: NSLayoutConstraint?
    private var topConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(chatMessage: ChatMessage) {
        usernameLabel.text = chatMessage.username
        messageLabel.text = chatMessage.text
        if chatMessage.isOwn {
            wrapperView.backgroundColor = .systemGreen
            messageLabel.textColor = .white
            leadingConstraint?.isActive = false
            usernameConstraint?.isActive = false
            trailingConstraint?.isActive = true
            topConstraint?.isActive = true
            usernameLabel.isHidden = true
        } else {
            wrapperView.backgroundColor = .imp.lightGray
            messageLabel.textColor = .black
            trailingConstraint?.isActive = false
            topConstraint?.isActive = false
            usernameLabel.isHidden = false
            leadingConstraint?.isActive = true
            usernameConstraint?.isActive = true
        }
    }

    private func configure() {
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrapperView)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(messageLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(usernameLabel)

        usernameLabel.font = .systemFont(ofSize: 12, weight: .bold)
        messageLabel.font = .systemFont(ofSize: 14)
        usernameLabel.numberOfLines = 1
        messageLabel.numberOfLines = 0
        wrapperView.layer.cornerRadius = 8

        leadingConstraint = wrapperView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horisontalOffsets)
        trailingConstraint = wrapperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horisontalOffsets)
        usernameConstraint = messageLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: Constants.labelSpacing)
        topConstraint = messageLabel.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: Constants.labelInsets)

        NSLayoutConstraint.activate([
            wrapperView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: Constants.horisontalOffsets),
            wrapperView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -Constants.horisontalOffsets),
            wrapperView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalOffests),
            wrapperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalOffests),

            usernameLabel.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: Constants.labelInsets),
            usernameLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: Constants.labelInsets),
            usernameLabel.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -Constants.labelInsets),

            messageLabel.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -Constants.labelInsets),
            messageLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: Constants.labelInsets),
            messageLabel.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -Constants.labelInsets)
        ])
        usernameConstraint?.isActive = true
    }


}
