import Foundation
import UIKit

extension CompositionVisibilityTableViewCell {
    private enum Constants {
        static let labelSpacing: CGFloat = 2
        static let verticalOffsets: CGFloat = 16
        static let horizontalOffsets: CGFloat = 16
    }
}

final class CompositionVisibilityTableViewCell: WrapperTableViewCell {
    static let reuseIdentifier = "CompositionVisibilityTableViewCell"

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let changeButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Изменить"
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = .imp.primary
        configuration.titleTextAttributesTransformer = .init { containter in
            var outgoingContainer = containter
            outgoingContainer.font = .boldSystemFont(ofSize: 12)
            return outgoingContainer
        }
        return .init(configuration: configuration)
    }()

    private var onChangeButtonTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(visibility: CompositionVisibility, onChangeButtonTapped: @escaping () -> Void) {
        self.onChangeButtonTapped = onChangeButtonTapped
        update(visibility: visibility)
    }

    func update(visibility: CompositionVisibility) {
        switch visibility {
        case .private:
            titleLabel.text = "Приватная"
            subtitleLabel.text = "Композицию видите вы и редакторы"
        case .public:
            titleLabel.text = "Публичная"
            subtitleLabel.text = "Композицию видят все"
        }
    }

    private func configure() {
        titleLabel.role(.title)
        subtitleLabel.role(.secondary)
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .secondaryLabel

        changeButton.addTarget(self, action: #selector(onChangeButtonTapped(_:)), for: .touchUpInside)
    }

    private func layout() {
        let labelStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStackView.axis = .vertical
        labelStackView.spacing = Constants.labelSpacing
        labelStackView.alignment = .leading

        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        changeButton.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(labelStackView)
        wrapperView.addSubview(changeButton)

        NSLayoutConstraint.activate([
            labelStackView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: Constants.horizontalOffsets),
            labelStackView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: Constants.verticalOffsets),
            labelStackView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -Constants.verticalOffsets),

            changeButton.centerYAnchor.constraint(equalTo: labelStackView.centerYAnchor),
            changeButton.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -Constants.horizontalOffsets)
        ])
    }

    @objc
    private func onChangeButtonTapped(_ sender: UIButton) {
        onChangeButtonTapped?()
    }
}
