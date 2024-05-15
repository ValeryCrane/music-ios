import Foundation
import UIKit

extension CompositionHistoryEventTableViewCell {
    private enum Constants {
        static let cellHeight: CGFloat = 80
        static let pathWidth: CGFloat = 4
        static let checkpointDiameter: CGFloat = 16
        static let horizontalOffsets: CGFloat = 32
        static let labelOffset: CGFloat = 16
        static let labelSpacing: CGFloat = 2
    }
}

final class CompositionHistoryEventTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CompositionHistoryEventTableViewCell"

    private let leadingPathView = UIView()
    private let trailingPathView = UIView()
    private let checkpointView = UIView()
    private let usernameLabel = UILabel()
    private let timeChangedLabel = UILabel()
    private let openCompositionButton = UIButton(configuration: {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .init(systemName: "chevron.right.circle")
        return configuration
    }())

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(compositionHistoryEvent: CompositionHistoryEvent, isFirst: Bool, isLast: Bool) {
        usernameLabel.text = compositionHistoryEvent.creator.username
        timeChangedLabel.text = compositionHistoryEvent.timeCreated.stringRepresentation()
        leadingPathView.layer.cornerRadius = isFirst ? Constants.pathWidth / 2 : 0
        trailingPathView.layer.cornerRadius = isLast ? Constants.pathWidth / 2 : 0
    }

    private func configure() {
        leadingPathView.backgroundColor = .black
        trailingPathView.backgroundColor = .black
        checkpointView.backgroundColor = .black
        usernameLabel.role(.title)
        timeChangedLabel.role(.secondary)
        timeChangedLabel.textColor = .secondaryLabel
        checkpointView.layer.cornerRadius = Constants.checkpointDiameter / 2
    }

    private func layout() {
        let labelStackView = UIStackView(arrangedSubviews: [usernameLabel, timeChangedLabel])
        labelStackView.axis = .vertical
        labelStackView.spacing = Constants.labelSpacing
        labelStackView.alignment = .leading

        [leadingPathView, trailingPathView, checkpointView, labelStackView, openCompositionButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }

        NSLayoutConstraint.activate([
            leadingPathView.topAnchor.constraint(equalTo: contentView.topAnchor),
            leadingPathView.bottomAnchor.constraint(equalTo: contentView.centerYAnchor),
            leadingPathView.heightAnchor.constraint(equalToConstant: Constants.cellHeight / 2),
            leadingPathView.widthAnchor.constraint(equalToConstant: Constants.pathWidth),
            leadingPathView.centerXAnchor.constraint(equalTo: checkpointView.centerXAnchor),

            trailingPathView.topAnchor.constraint(equalTo: contentView.centerYAnchor),
            trailingPathView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            trailingPathView.heightAnchor.constraint(equalToConstant: Constants.cellHeight / 2),
            trailingPathView.widthAnchor.constraint(equalToConstant: Constants.pathWidth),
            trailingPathView.centerXAnchor.constraint(equalTo: checkpointView.centerXAnchor),

            checkpointView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkpointView.heightAnchor.constraint(equalToConstant: Constants.checkpointDiameter),
            checkpointView.widthAnchor.constraint(equalToConstant: Constants.checkpointDiameter),
            checkpointView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalOffsets),

            labelStackView.centerYAnchor.constraint(equalTo: checkpointView.centerYAnchor),
            labelStackView.leadingAnchor.constraint(equalTo: checkpointView.trailingAnchor, constant: Constants.labelOffset),

            openCompositionButton.centerYAnchor.constraint(equalTo: checkpointView.centerYAnchor),
            openCompositionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalOffsets / 2)
        ])
    }
}

fileprivate extension Date {
    func stringRepresentation() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "ru_RU")
        dateFormatter.setLocalizedDateFormatFromTemplate("dd MMMM")
        return dateFormatter.string(from: self)
    }
}
