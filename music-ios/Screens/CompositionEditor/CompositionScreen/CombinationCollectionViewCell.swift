import Foundation
import UIKit

extension CombinationCollectionViewCell {
    private enum Constants {
        static let paddings: CGFloat = 16
        static let buttonHeight: CGFloat = 24
    }
}

final class CombinationCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CombinationCollectionViewCell"
    
    private let nameLabel = UILabel()
    private let effectsButton = UIButton()
    private let playButton = UIButton()

    private var onPlayButtonTapped: (() -> Void)?
    private var onEffectsButtonTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(
        combinationName: String,
        isPlaying: Bool,
        onPlayButtonTapped: @escaping () -> Void,
        onEffectsButtonTapped: @escaping () -> Void
    ) {
        nameLabel.text = combinationName
        playButton.setImage(.init(systemName: isPlaying ? "pause.fill" : "play.fill"), for: .normal)
        playButton.scaleImage(toHeight: Constants.buttonHeight)

        self.onPlayButtonTapped = onPlayButtonTapped
        self.onEffectsButtonTapped = onEffectsButtonTapped
    }
    
    private func configure() {
        contentView.backgroundColor = .imp.lightGray
        contentView.layer.cornerRadius = .defaultCornerRadius

        nameLabel.role(.title)
        nameLabel.numberOfLines = 2

        effectsButton.setImage(.init(systemName: "slider.horizontal.3"), for: .normal)
        effectsButton.scaleImage(toHeight: Constants.buttonHeight)

        playButton.addTarget(self, action: #selector(onPlayButtonTapped(_:)), for: .touchUpInside)
        effectsButton.addTarget(self, action: #selector(onEffectsButtonTapped(_:)), for: .touchUpInside)
    }

    private func layout() {
        [nameLabel, effectsButton, playButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddings),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.paddings),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddings),

            effectsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddings),
            effectsButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddings),

            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddings),
            playButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddings)
        ])
    }

    @objc
    private func onPlayButtonTapped(_ sender: UIButton) {
        onPlayButtonTapped?()
    }

    @objc
    private func onEffectsButtonTapped(_ sender: UIButton) {
        onEffectsButtonTapped?()
    }
}
