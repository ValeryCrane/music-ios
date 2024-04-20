import Foundation
import UIKit

extension ChooseMelodyTableViewCell {
    enum Constants {
        static let buttonWidth: CGFloat = 20
        static let titleSpacing: CGFloat = 8
        static let horizontalOffsets: CGFloat = 16
        static let verticalOffsets: CGFloat = 16
        static let verticalInsets: CGFloat = 4
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
    
    private let wrapperView = UIView()
    
    private let nameLabel = UILabel()
    private let playButton = UIButton()
    private let activityIndicator = UIActivityIndicatorView()
    
    private var melody: MelodyMiniature?
    private var state: State = .paused
    private var onPlayButtonPressed: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        wrapperView.backgroundColor = .imp.lightGray
        wrapperView.layer.cornerRadius = .defaultCornerRadius
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
        
        playButton.tintColor = .darkGray
        playButton.addTarget(self, action: #selector(onPlayButtonPressed(_:)), for: .touchUpInside)
        updatePlayButton()
    }
    
    private func layout() {
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrapperView)
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalInsets),
            wrapperView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalInsets),
        ])
        
        wrapperView.addSubview(nameLabel)
        wrapperView.addSubview(playButton)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: Constants.horizontalOffsets),
            nameLabel.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: Constants.verticalOffsets),
            nameLabel.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -Constants.verticalOffsets),
            
            playButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: Constants.titleSpacing),
            playButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            playButton.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -Constants.horizontalOffsets)
        ])
    }
    
    private func updatePlayButton() {
        switch state {
        case .paused:
            playButton.isHidden = false
            let playButtonImage = UIImage(systemName: "play.fill")
            playButton.setImage(playButtonImage, for: .normal)
        case .loading:
            playButton.isHidden = true
            activityIndicator.isHidden = false
        case .playing:
            playButton.isHidden = false
            let playButtonImage = UIImage(systemName: "pause.fill")
            playButton.setImage(playButtonImage, for: .normal)
        }

        playButton.scaleImage(toWidth: Constants.buttonWidth)
    }
    
    @objc
    private func onPlayButtonPressed(_ sender: UIButton) {
        onPlayButtonPressed?()
    }
}
