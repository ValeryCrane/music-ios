import Foundation
import UIKit

extension ChooseKeyboardTableViewCell {
    enum Constants {
        static let buttonWidth: CGFloat = 20
        static let horizontalOffsets: CGFloat = 32
        static let verticalOffsets: CGFloat = 16
        static let labelSpacing: CGFloat = 2
        static let currentIndicatorSize: CGFloat = 8
    }
}

extension ChooseKeyboardTableViewCell {
    enum State {
        case paused
        case loading
    }
}

final class ChooseKeyboardTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ChooseKeyboardTableViewCell"

    private let nameLabel = UILabel()
    private let numberOfKeysLabel = UILabel()
    private let playButton = UIButton()
    private let activityIndicator = UIActivityIndicatorView()
    private let currentIndicator = UIView()

    private var keyboard: KeyboardMiniature?
    private var state: State = .paused
    private var onPlayButtonPressed: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(
        isCurrent: Bool,
        keyboard: KeyboardMiniature,
        state: State,
        onPlayButtonPressed: @escaping () -> Void
    ) {
        self.keyboard = keyboard
        self.state = state
        self.onPlayButtonPressed = onPlayButtonPressed

        nameLabel.text = keyboard.name
        numberOfKeysLabel.text = "\(keyboard.numberOfKeys) клавиш"
        currentIndicator.isHidden = !isCurrent
    }

    func updateState(_ state: State) {
        self.state = state
        updatePlayButton()
    }

    private func configure() {
        nameLabel.role(.title)
        numberOfKeysLabel.role(.secondary)
        activityIndicator.hidesWhenStopped = true

        playButton.tintColor = .imp.primary
        playButton.setImage(.init(systemName: "play.fill"), for: .normal)
        playButton.addTarget(self, action: #selector(onPlayButtonPressed(_:)), for: .touchUpInside)
        updatePlayButton()

        currentIndicator.backgroundColor = .imp.complementary
        currentIndicator.layer.cornerRadius = Constants.currentIndicatorSize / 2
    }

    private func layout() {
        let infoStackView = UIStackView(arrangedSubviews: [nameLabel, numberOfKeysLabel])
        infoStackView.axis = .vertical
        infoStackView.alignment = .leading
        infoStackView.spacing = Constants.labelSpacing

        [infoStackView, playButton, currentIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalOffsets),
            infoStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalOffsets),
            infoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalOffsets),

            playButton.centerYAnchor.constraint(equalTo: infoStackView.centerYAnchor),
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalOffsets),

            currentIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            currentIndicator.heightAnchor.constraint(equalToConstant: Constants.currentIndicatorSize),
            currentIndicator.widthAnchor.constraint(equalToConstant: Constants.currentIndicatorSize),
            currentIndicator.centerXAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.horizontalOffsets / 2
            )
        ])

        playButton.scaleImage(toWidth: Constants.buttonWidth)
    }

    private func updatePlayButton() {
        switch state {
        case .paused:
            playButton.isHidden = false
            activityIndicator.stopAnimating()
        case .loading:
            playButton.isHidden = true
            activityIndicator.startAnimating()
        }
    }

    @objc
    private func onPlayButtonPressed(_ sender: UIButton) {
        onPlayButtonPressed?()
    }
}
