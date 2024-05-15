import Foundation
import UIKit

extension NiceStepper {
    private enum Constants {
        static let viewSpacing: CGFloat = 8
    }
}

class NiceStepper: UIControl {
    let minimumValue: Int
    let maximumValue: Int

    override var isEnabled: Bool {
        didSet {
            updateState()
        }
    }

    private(set) var value: Int
    
    private let wrappedView: UIView?
    private let plusButton = UIButton()
    private let minusButton = UIButton()
    
    init(value: Int, minimumValue: Int, maximumValue: Int, wrappedView: UIView? = nil) {
        self.value = value
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.wrappedView = wrappedView
        
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
        plusButton.setImage(.init(systemName: "plus.circle"), for: .normal)
        plusButton.tintColor = .imp.primary
        plusButton.addTarget(self, action: #selector(plusButtonPressed(_:)), for: .touchUpInside)
        
        minusButton.setImage(.init(systemName: "minus.circle"), for: .normal)
        minusButton.tintColor = .imp.primary
        minusButton.addTarget(self, action: #selector(minusButtonPressed(_:)), for: .touchUpInside)
    }
    
    private func layout() {
        let stackView = UIStackView(arrangedSubviews: [minusButton, plusButton])
        
        stackView.axis = .horizontal
        stackView.spacing = Constants.viewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(greaterThanOrEqualTo: plusButton.heightAnchor),
            stackView.heightAnchor.constraint(greaterThanOrEqualTo: minusButton.heightAnchor)
        ])
        
        if let wrappedView = wrappedView {
            stackView.insertArrangedSubview(wrappedView, at: 1)
            stackView.heightAnchor.constraint(greaterThanOrEqualTo: wrappedView.heightAnchor).isActive = true
        }
    }
    
    private func updateState() {
        minusButton.isEnabled = value != minimumValue && isEnabled
        plusButton.isEnabled = value != maximumValue && isEnabled
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
