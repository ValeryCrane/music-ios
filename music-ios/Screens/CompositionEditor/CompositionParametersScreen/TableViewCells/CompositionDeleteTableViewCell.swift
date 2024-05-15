import Foundation
import UIKit

extension CompositionDeleteTableViewCell {
    private enum Constants {
        static let verticalOffsets: CGFloat = 16
        static let horizontalOffsets: CGFloat = 16
    }
}

final class CompositionDeleteTableViewCell: WrapperTableViewCell {
    static let reuseIdentifier = "CompositionDeleteTableViewCell"

    private let titleLabel = UILabel()
    private let deleteButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .init(systemName: "trash.fill")
        configuration.baseForegroundColor = .systemRed
        configuration.contentInsets = .zero
        return .init(configuration: configuration)
    }()

    private var onDeleteButtonTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(onDeleteButtonTapped: @escaping () -> Void) {
        self.onDeleteButtonTapped = onDeleteButtonTapped
    }

    private func configure() {
        wrapperView.layer.borderColor = UIColor.systemRed.cgColor
        wrapperView.layer.borderWidth = 1
        titleLabel.text = "Удалить композицию"
        titleLabel.role(.primary)
        titleLabel.textColor = .systemRed

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onViewTapped(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    private func layout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(titleLabel)
        wrapperView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: Constants.horizontalOffsets),
            titleLabel.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: Constants.verticalOffsets),
            titleLabel.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -Constants.verticalOffsets),

            deleteButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -Constants.horizontalOffsets)
        ])
    }

    @objc
    private func onViewTapped(_ sender: UITapGestureRecognizer) {
        onDeleteButtonTapped?()
    }
}
