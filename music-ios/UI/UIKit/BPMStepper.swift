import Foundation
import UIKit

extension BPMStepper {
    private enum Constants {
        static let viewSpacing: CGFloat = 8
    }
}

final class BPMStepper: UIControl {
    let minimumValue: Int
    let maximumValue: Int
    
    private(set) var value: Int
    
    private let label = UILabel()
    private let plusButton = UIButton()
    private let minusButton = UIButton()
    
    init(value: Int, minimumValue: Int, maximumValue: Int) {
        self.value = value
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        
        super.init(frame: .zero)
        
        configure()
        layout()
        updateState()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        label.role(.title)
        
        plusButton.setImage(.init(systemName: "plus.circle"), for: .normal)
        plusButton.tintColor = .imp.primary
        plusButton.addTarget(self, action: #selector(plusButtonPressed(_:)), for: .touchUpInside)
        
        minusButton.setImage(.init(systemName: "minus.circle"), for: .normal)
        minusButton.tintColor = .imp.primary
        minusButton.addTarget(self, action: #selector(minusButtonPressed(_:)), for: .touchUpInside)
    }
    
    private func layout() {
        [label, plusButton, minusButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            minusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            plusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            minusButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: Constants.viewSpacing),
            plusButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: Constants.viewSpacing),
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func updateState() {
        label.text = "\(value)bpm"
        minusButton.isEnabled = value != minimumValue
        plusButton.isEnabled = value != maximumValue
    }
    
    @objc
    private func plusButtonPressed(_ sender: UIButton) {
        value += 1
        updateState()
        sendActions(for: .valueChanged)
    }
    
    @objc
    private func minusButtonPressed(_ sender: UIButton) {
        value -= 1
        updateState()
        sendActions(for: .valueChanged)
    }
}
