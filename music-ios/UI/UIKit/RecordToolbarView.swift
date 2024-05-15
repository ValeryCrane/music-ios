import Foundation
import UIKit

protocol RecordToolbarViewDelegate: AnyObject {
    func recordToolbarView(didChangeIsMicMuted isMicMuted: Bool)
    func recordToolbarViewDidStartRecording()
    func recordToolbarViewDidEndRecording()
    func saveButtonTapped()
}

extension RecordToolbarView {
    private enum Constants {
        static let buttonSize: CGFloat = 48
        static let buttonSpacing: CGFloat = 32
        static let horizontalOffsets: CGFloat = 16
        static let verticalOffsets: CGFloat = 16
    }
}

final class RecordToolbarView: UIView {
    weak var delegate: RecordToolbarViewDelegate?
    
    private let backgroundView = UIView()
    private let placeholderLabel = UILabel()
    private let micButton = UIButton()
    private let recordButton = UIButton()
    private let saveCompositionButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Сохранить композицию"
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = .imp.primary
        configuration.titleTextAttributesTransformer = .init { containter in
            var outgoingContainer = containter
            outgoingContainer.font = .boldSystemFont(ofSize: 12)
            return outgoingContainer
        }
        return .init(configuration: configuration)
    }()

    private(set) var isMicMuted: Bool = false {
        didSet {
            updateMicButtonState()
            delegate?.recordToolbarView(didChangeIsMicMuted: isMicMuted)
        }
    }
    private(set) var isRecording: Bool = false {
        didSet {
            updateRecordButtonState()
            if isRecording {
                delegate?.recordToolbarViewDidStartRecording()
            } else {
                delegate?.recordToolbarViewDidEndRecording()
            }
        }
    }

    private var backgroundViewTopConstraint: NSLayoutConstraint?
    private var saveButtonTopConstraint: NSLayoutConstraint?

    init() {
        super.init(frame: .zero)
        
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = .defaultCornerRadius
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 0.05
        backgroundView.layer.shadowRadius = 4
        configure()
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showSaveCompositionButton() {
        backgroundViewTopConstraint?.constant = 48
        saveButtonTopConstraint?.constant = 56
        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.2) {
            self.saveButtonTopConstraint?.constant = 8
            self.layoutIfNeeded()
        }
    }

    func hideSaveCompositionButton() {
        UIView.animate(withDuration: 0.2) {
            self.saveButtonTopConstraint?.constant = 56
            self.layoutIfNeeded()
        }

        backgroundViewTopConstraint?.constant = 0
        saveButtonTopConstraint?.constant = 8
    }

    private func configure() {
        updateMicButtonState()
        updateRecordButtonState()
        micButton.layer.cornerRadius = .defaultCornerRadius
        recordButton.layer.cornerRadius = .defaultCornerRadius
        saveCompositionButton.layer.cornerRadius = .defaultCornerRadius

        placeholderLabel.role(.title)
        placeholderLabel.text = "Запись композиции"
        placeholderLabel.isHidden = true

        micButton.addTarget(self, action: #selector(onMicButtonPressed(_:)), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(onRecordButtonPressed(_:)), for: .touchUpInside)
        saveCompositionButton.addTarget(self, action: #selector(onSaveCompositionButtonPressed(_:)), for: .touchUpInside)
    }
    
    private func layout() {
        let buttonStackView = UIStackView(arrangedSubviews: [micButton, recordButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = Constants.buttonSpacing
        
        [backgroundView, buttonStackView, micButton, recordButton, placeholderLabel, saveCompositionButton].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        addSubview(saveCompositionButton)
        addSubview(backgroundView)
        backgroundView.addSubview(buttonStackView)
        backgroundView.addSubview(placeholderLabel)

        let backgroundViewTopConstraint = backgroundView.topAnchor.constraint(equalTo: topAnchor)
        let saveButtonTopConstraint = saveCompositionButton.topAnchor.constraint(equalTo: topAnchor, constant: 8)
        self.backgroundViewTopConstraint = backgroundViewTopConstraint
        self.saveButtonTopConstraint = saveButtonTopConstraint
        NSLayoutConstraint.activate([
            backgroundViewTopConstraint,
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            buttonStackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: Constants.verticalOffsets),
            buttonStackView.bottomAnchor.constraint(lessThanOrEqualTo: backgroundView.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalOffsets),
            buttonStackView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            micButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            recordButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            placeholderLabel.centerYAnchor.constraint(equalTo: buttonStackView.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: Constants.horizontalOffsets),

            saveCompositionButton.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            saveButtonTopConstraint
        ])
    }
    
    private func updateMicButtonState() {
        UIView.animate(withDuration: 0.2) {
            if self.isMicMuted {
                self.micButton.setImage(.init(systemName: "mic"), for: .normal)
                self.micButton.tintColor = .darkGray
                self.micButton.backgroundColor = .imp.lightGray
            } else {
                self.micButton.setImage(.init(systemName: "mic.slash"), for: .normal)
                self.micButton.tintColor = .imp.lightGray
                self.micButton.backgroundColor = .darkGray
            }
        }
    }
    
    private func updateRecordButtonState() {
        UIView.animate(withDuration: 0.2) {
            if self.isRecording {
                self.recordButton.setImage(.init(systemName: "stop.fill"), for: .normal)
                self.recordButton.tintColor = .imp.lightGray
                self.recordButton.backgroundColor = .systemRed
            } else {
                self.recordButton.setImage(.init(systemName: "record.circle"), for: .normal)
                self.recordButton.tintColor = .systemRed
                self.recordButton.backgroundColor = .imp.lightGray
            }
        }
    }
    
    @objc
    private func onMicButtonPressed(_ sender: UIButton) {
        isMicMuted.toggle()
    }
    
    @objc
    private func onRecordButtonPressed(_ sender: UIButton) {
        isRecording.toggle()
    }

    @objc
    private func onSaveCompositionButtonPressed(_ sender: UIButton) {
        delegate?.saveButtonTapped()
    }
}
