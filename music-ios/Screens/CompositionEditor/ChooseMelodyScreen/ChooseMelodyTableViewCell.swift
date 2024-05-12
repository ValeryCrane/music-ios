import Foundation
import UIKit

extension ChooseMelodyTableViewCell {
    enum Constants {
        static let buttonWidth: CGFloat = 20
        static let titleSpacing: CGFloat = 8
        static let horizontalOffsets: CGFloat = 32
        static let verticalOffsets: CGFloat = 24
    }
}

extension ChooseMelodyTableViewCell {
    enum State {
        case paused
        case loading
        case playing
    }
}

final class ChooseMelodyTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ChooseSampleViewCell"
    
    private let nameLabel = UILabel()
    private let playButton = UIButton()
    private let activityIndicator = UIActivityIndicatorView()
    
    private var melody: MelodyMiniature?
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
    
    func setup(melody: MelodyMiniature, state: State, onPlayButtonPressed: @escaping () -> Void) {
        self.melody = melody
        self.state = state
        self.onPlayButtonPressed = onPlayButtonPressed
        nameLabel.text = melody.name
    }
    
    func updateState(_ state: State) {
        self.state = state
        updatePlayButton()
    }
    
    private func configure() {
        nameLabel.role(.title)
        activityIndicator.hidesWhenStopped = true
        
        playButton.tintColor = .imp.primary
        playButton.addTarget(self, action: #selector(onPlayButtonPressed(_:)), for: .touchUpInside)
        updatePlayButton()
    }
    
    private func layout() {
        [nameLabel, playButton, activityIndicator].forEach { view in
            contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalOffsets),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalOffsets),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalOffsets),

            playButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: Constants.titleSpacing),
            playButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalOffsets),

            activityIndicator.centerXAnchor.constraint(equalTo: playButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: playButton.centerYAnchor)
        ])
    }
    
    private func updatePlayButton() {
        switch state {
        case .paused:
            playButton.isHidden = false
            let playButtonImage = UIImage(systemName: "play.fill")
            playButton.setImage(playButtonImage, for: .normal)
            activityIndicator.stopAnimating()
        case .loading:
            playButton.isHidden = true
            activityIndicator.startAnimating()
        case .playing:
            playButton.isHidden = false
            let playButtonImage = UIImage(systemName: "pause.fill")
            playButton.setImage(playButtonImage, for: .normal)
            activityIndicator.stopAnimating()
        }

        playButton.scaleImage(toWidth: Constants.buttonWidth)
    }
    
    @objc
    private func onPlayButtonPressed(_ sender: UIButton) {
        onPlayButtonPressed?()
    }
}
