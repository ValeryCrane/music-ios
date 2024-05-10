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
    let type: EffectPropertyType
    private(set) var value: Float

    private let stackView = UIStackView()
    private let slider = UISlider()
    private let accelerometerButton = UIButton()

    override var intrinsicContentSize: CGSize {
        .init(
            width: UIView.noIntrinsicMetric,
            height: Constants.controlHeight
        )
    }

    init(type: EffectPropertyType, initialValue: Float) {
        self.type = type
        self.value = initialValue

        super.init(frame: .zero)
        
        configure()
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        slider.minimumValue = type.minValue
        slider.maximumValue = type.maxValue
        slider.value = value

        slider.setThumbImage(.init(named: "effect_slider_thumb"), for: .normal)
        slider.minimumValueImage = type.image
        slider.tintColor = .imp.secondary
        slider.minimumTrackTintColor = .imp.complementary

        accelerometerButton.setImage(.init(systemName: "rectangle.portrait.rotate"), for: .normal)
        slider.addTarget(self, action: #selector(onSliderChangeValue(_:)), for: .valueChanged)
    }
    
    private func layout() {
        let stackView = UIStackView(arrangedSubviews: [slider, accelerometerButton])
        stackView.axis = .horizontal
        stackView.spacing = Constants.elementSpacing
        stackView.alignment = .center

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: Constants.controlHeight)
        ])

        accelerometerButton.scaleImage(toWidth: Constants.buttonWidth)
    }
    
    @objc
    private func onSliderChangeValue(_ sender: UISlider) {
        value = sender.value
        sendActions(for: .valueChanged)
    }
}
