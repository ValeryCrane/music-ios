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
    
    private var combination: MutableCombination? {
        didSet {
            nameLabel.text = combination?.name
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(combination: MutableCombination) {
        self.combination = combination
    }
    
    private func configure() {
        contentView.backgroundColor = .imp.lightGray
        contentView.layer.cornerRadius = .defaultCornerRadius
        
        configureNameLabel()
        configureButtons()
    }
    
    private func configureNameLabel() {
        nameLabel.role(.title)
        nameLabel.numberOfLines = 2
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddings),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.paddings),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddings)
        ])
    }
    
    private func configureButtons() {
        let effectsImage = UIImage(systemName: "slider.horizontal.3")
        let effectsButtonWidth = (effectsImage?.size.width ?? 0) * Constants.buttonHeight / (effectsImage?.size.height ?? 0)
        effectsButton.setImage(effectsImage, for: .normal)
        effectsButton.tintColor = .imp.primary
        effectsButton.contentVerticalAlignment = .fill
        effectsButton.contentHorizontalAlignment = .fill
        
        let playImage = UIImage(systemName: "play.fill")
        let playButtonWidth = (playImage?.size.width ?? 0) * Constants.buttonHeight / (playImage?.size.height ?? 0)
        playButton.setImage(playImage, for: .normal)
        playButton.tintColor = .imp.primary
        playButton.contentVerticalAlignment = .fill
        playButton.contentHorizontalAlignment = .fill
        
        effectsButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(effectsButton)
        contentView.addSubview(playButton)
        NSLayoutConstraint.activate([
            effectsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddings),
            effectsButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddings),
            effectsButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            effectsButton.widthAnchor.constraint(equalToConstant: effectsButtonWidth),
            
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddings),
            playButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddings),
            playButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            playButton.widthAnchor.constraint(equalToConstant: playButtonWidth)
        ])
    }
}
