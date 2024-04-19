import Foundation
import UIKit

protocol RecordToolbarViewDelegate: AnyObject {
    func recordToolbarView(didChangeIsMicMuted isMicMuted: Bool)
    func recordToolbarViewDidStartRecording()
    func recordToolbarViewDidEndRecording()
}

extension RecordToolbarView {
    private enum Constants {
        static let buttonSize: CGFloat = 48
        static let buttonSpacing: CGFloat = 8
        static let horizontalOffsets: CGFloat = 16
        static let verticalOffsets: CGFloat = 16
    }
}

final class RecordToolbarView: UIView {
    weak var delegate: RecordToolbarViewDelegate?
    
    private let placeholderLabel = UILabel()
    private let micButton = UIButton()
    private let recordButton = UIButton()
    
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
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        layer.cornerRadius = .defaultCornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 4
        configure()
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        updateMicButtonState()
        updateRecordButtonState()
        micButton.layer.cornerRadius = .defaultCornerRadius
        recordButton.layer.cornerRadius = .defaultCornerRadius
        
        placeholderLabel.role(.title)
        placeholderLabel.text = "Запись композиции"
        
        micButton.addTarget(self, action: #selector(onMicButtonPressed(_:)), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(onRecordButtonPressed(_:)), for: .touchUpInside)
    }
    
    
    private func layout() {
        let buttonStackView = UIStackView(arrangedSubviews: [micButton, recordButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = Constants.buttonSpacing
        
        [buttonStackView, micButton, recordButton, placeholderLabel].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        addSubview(buttonStackView)
        addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalOffsets),
            buttonStackView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalOffsets),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalOffsets),
            buttonStackView.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            micButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            recordButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            placeholderLabel.centerYAnchor.constraint(equalTo: buttonStackView.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalOffsets)
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
}
