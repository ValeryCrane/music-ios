import Foundation
import UIKit

extension CompositionUserMiniatureTableViewCell {
    private enum Constants {
        static let avatarSize: CGFloat = 48
        static let usernameSpacing: CGFloat = 16
        static let verticalOffsets: CGFloat = 12
        static let horizontalOffsets: CGFloat = 16
    }
}

final class CompositionUserMiniatureTableViewCell: WrapperTableViewCell {
    static let reuseIdentifier = "CompositionUserMiniatureTableViewCell"

    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()

    private var onLongTap: (() -> Void)?

    private var loadAvatarTask: Task<Void, Error>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(user: User, onLongTap: (() -> Void)? = nil) {
        loadAvatarTask?.cancel()
        avatarImageView.image = nil

        usernameLabel.text = user.username
        loadAvatarTask = Task {
            avatarImageView.image = try await loadAvatarImage(url: user.avatarURL)
        }

        self.onLongTap = onLongTap
    }

    private func configure() {
        usernameLabel.role(.title)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = Constants.avatarSize / 2
        avatarImageView.backgroundColor = .lightGray
        avatarImageView.clipsToBounds = true

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongTap(_:)))
        addGestureRecognizer(longPressGestureRecognizer)
    }

    private func layout() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(avatarImageView)
        wrapperView.addSubview(usernameLabel)

        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: Constants.horizontalOffsets),
            avatarImageView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: Constants.verticalOffsets),
            avatarImageView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -Constants.verticalOffsets),

            usernameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Constants.usernameSpacing)
        ])
    }

    private func loadAvatarImage(url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let image = UIImage(data: data) {
            return image
        } else {
            throw RuntimeError("Не удалось загрузить аватар пользователя")
        }
    }

    @objc
    private func onLongTap(_ sender: UILongPressGestureRecognizer) {
        onLongTap?()
    }
}
