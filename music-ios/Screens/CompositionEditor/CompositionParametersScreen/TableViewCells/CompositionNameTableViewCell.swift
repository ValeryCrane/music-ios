import Foundation
import UIKit

extension CompositionNameTableViewCell {
    private enum Constants {
        static let verticalOffsets: CGFloat = 16
        static let horizontalOffsets: CGFloat = 16
    }
}

final class CompositionNameTableViewCell: WrapperTableViewCell {
    static let reuseIdentifier = "CompositionNameTableViewCell"

    private let compositionNameLabel = UILabel()
    private let changeNameButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .init(systemName: "pencil")
        configuration.baseForegroundColor = .gray
        configuration.contentInsets = .zero
        return .init(configuration: configuration)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(name: String) {
        compositionNameLabel.text = name
    }

    private func configure() {
        compositionNameLabel.role(.title)
    }

    private func layout() {
        compositionNameLabel.translatesAutoresizingMaskIntoConstraints = false
        changeNameButton.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(compositionNameLabel)
        wrapperView.addSubview(changeNameButton)

        NSLayoutConstraint.activate([
            compositionNameLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: Constants.horizontalOffsets),
            compositionNameLabel.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: Constants.verticalOffsets),
            compositionNameLabel.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -Constants.verticalOffsets),

            changeNameButton.centerYAnchor.constraint(equalTo: compositionNameLabel.centerYAnchor),
            changeNameButton.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -Constants.horizontalOffsets)
        ])
    }
}
