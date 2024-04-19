import Foundation
import UIKit

extension EffectControl {
    private enum Constants {
        static let elementSpacing: CGFloat = 8
    }
}

final class EffectControl: UIControl {
    
    private let nameLabel = UILabel()
    private let sliderStackView = UIStackView()
    
    private let effect: MutableEffect
    
    init(effect: MutableEffect) {
        self.effect = effect
        
        super.init(frame: .zero)
        
        configure()
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        nameLabel.text = effect.type.name
        nameLabel.role(.title)
        nameLabel.textAlignment = .center
        
        sliderStackView.axis = .vertical
        sliderStackView.spacing = Constants.elementSpacing
    }
    
    private func layout() {
        sliderStackView.addArrangedSubview(nameLabel)
        for effectProperty in effect.properties {
            sliderStackView.addArrangedSubview(EffectPropertyControl(effectProperty: effectProperty))
        }
        
        addSubview(sliderStackView)
        sliderStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sliderStackView.topAnchor.constraint(equalTo: topAnchor),
            sliderStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sliderStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            sliderStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
