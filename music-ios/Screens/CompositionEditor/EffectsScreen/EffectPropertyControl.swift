import Foundation
import UIKit

extension EffectPropertyControl {
    enum Constants {
        static let buttonWidth: CGFloat = 24
        static let elementSpacing: CGFloat = 24
        static let controlHeight: CGFloat = 36
    }
}

final class EffectPropertyControl: UIControl {
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let slider = UISlider()
    private let accelerometerButton = UIButton()
    
    private let effectProperty: MutableEffectProperty
    
    init(effectProperty: MutableEffectProperty) {
        self.effectProperty = effectProperty
        
        super.init(frame: .zero)
        
        configure()
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        imageView.image = effectProperty.type.image
        imageView.contentMode = .scaleAspectFill
        slider.minimumValue = effectProperty.type.minValue
        slider.maximumValue = effectProperty.type.maxValue
        slider.value = effectProperty.value
        accelerometerButton.setImage(.init(systemName: "rectangle.portrait.rotate"), for: .normal)
        slider.addTarget(self, action: #selector(onSliderChangeValue(_:)), for: .touchUpInside)
    }
    
    private func layout() {
        let stackView = UIStackView(arrangedSubviews: [imageView, slider, accelerometerButton])
        [imageView, slider, accelerometerButton].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.axis = .horizontal
        stackView.spacing = Constants.elementSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        accelerometerButton.scaleImage(toWidth: Constants.buttonWidth)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let imageViewHeight = (imageView.image?.size.height ?? .zero) * Constants.buttonWidth / (imageView.image?.size.width ?? .zero)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.buttonWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageViewHeight),
            
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: Constants.controlHeight)
        ])
    }
    
    @objc
    private func onSliderChangeValue(_ sender: UISlider) {
        effectProperty.value = sender.value
    }
}
