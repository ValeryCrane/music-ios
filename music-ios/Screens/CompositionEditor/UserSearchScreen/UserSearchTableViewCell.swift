import Foundation
import UIKit

extension UserSearchTableViewCell {
    private enum Constants {
        static let imageSpacing: CGFloat = 16
        static let avatarSize: CGFloat = 40
        static let horizontalOffsets: CGFloat = 24
        static let verticalOffsets: CGFloat = 12
    }
}

final class UserSearchTableViewCell: UITableViewCell {
    static let reuseIdentifier = "UserSearchTableViewCell"
    static let estimatedHeight = Constants.avatarSize + Constants.verticalOffsets * 2

    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()

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

    func setup(user: User) {
        loadAvatarTask?.cancel()
        avatarImageView.image = nil

        usernameLabel.text = user.username
        loadAvatarTask = Task {
            avatarImageView.image = try await loadAvatarImage(url: user.avatarURL)
        }
    }
    
    private func configure() {
        usernameLabel.role(.title)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = Constants.avatarSize / 2
        avatarImageView.backgroundColor = .lightGray
        avatarImageView.clipsToBounds = true
    }

    private func layout() {
        [avatarImageView, usernameLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }

        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalOffsets),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalOffsets),
            avatarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalOffsets),

            usernameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Constants.imageSpacing)
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
}
