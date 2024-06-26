import Foundation
import UIKit

extension MelodyTableViewCell {
    enum Constants {
        static let buttonWidth: CGFloat = 28
        static let buttonSpacing: CGFloat = 8
        static let horizontalOffsets: CGFloat = 16
        static let verticalOffsets: CGFloat = 16
        static let verticalInsets: CGFloat = 4
    }
}

final class MelodyTableViewCell: UITableViewCell {
    static let reuseIdentifier = "MelodyTableViewCell"
    
    private let wrapperView = UIView()
    
    private let nameLabel = UILabel()
    private let editButton = UIButton()
    private let effectsButton = UIButton()
    private let muteButton = UIButton()

    private var onEditButtonTapped: (() -> Void)?
    private var onMuteButtonTapped: (() -> Void)?
    private var onEffectsButtonTapped: (() -> Void)?

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
    
    func setup(
        melodyMiniature: CombinationMelodyMiniature,
        onEditButtonTapped: @escaping () -> Void,
        onMuteButtonTapped: @escaping () -> Void,
        onEffectsButtonTapped: @escaping () -> Void
    ) {
        self.onEditButtonTapped = onEditButtonTapped
        self.onMuteButtonTapped = onMuteButtonTapped
        self.onEffectsButtonTapped = onEffectsButtonTapped
        update(melodyMiniature: melodyMiniature)
    }

    func update(melodyMiniature: CombinationMelodyMiniature) {
        nameLabel.text = melodyMiniature.name
        updateMuteButton(isMuted: melodyMiniature.isMuted)
    }

    private func configure() {
        nameLabel.role(.title)
        
        muteButton.tintColor = .darkGray
        editButton.tintColor = .imp.primary
        effectsButton.tintColor = .imp.primary
        
        let editButtonImage = UIImage(systemName: "pencil")
        editButton.setImage(editButtonImage, for: .normal)
        editButton.scaleImage(toWidth: Constants.buttonWidth)
        
        let effectsButtonImage = UIImage(systemName: "slider.horizontal.3")
        effectsButton.setImage(effectsButtonImage, for: .normal)
        effectsButton.scaleImage(toWidth: Constants.buttonWidth)
        
        editButton.addTarget(self, action: #selector(onEditButtonTapped(_:)), for: .touchUpInside)
        effectsButton.addTarget(self, action: #selector(onEffectsButtonTapped(_:)), for: .touchUpInside)
        muteButton.addTarget(self, action: #selector(onMuteButtonTapped(_:)), for: .touchUpInside)
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

        let buttonStack = UIStackView(arrangedSubviews: [editButton, effectsButton, muteButton])
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.spacing = Constants.buttonSpacing
        
        wrapperView.addSubview(nameLabel)
        wrapperView.addSubview(buttonStack)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: Constants.horizontalOffsets),
            nameLabel.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: Constants.verticalOffsets),
            nameLabel.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -Constants.verticalOffsets),
            
            buttonStack.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: Constants.buttonSpacing),
            buttonStack.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -Constants.horizontalOffsets)
        ])
    }
    
    private func updateMuteButton(isMuted: Bool) {
        let muteButtonImage = UIImage(systemName: isMuted ? "speaker.slash" : "speaker")
        muteButton.setImage(muteButtonImage, for: .normal)
        muteButton.scaleImage(toWidth: Constants.buttonWidth)
    }
    
    @objc
    private func onMuteButtonTapped(_ sender: UIButton) {
        onMuteButtonTapped?()
    }

    @objc
    private func onEditButtonTapped(_ sender: UIButton) {
        onEditButtonTapped?()
    }
    
    @objc
    private func onEffectsButtonTapped(_ sender: UIButton) {
        onEffectsButtonTapped?()
    }
}
