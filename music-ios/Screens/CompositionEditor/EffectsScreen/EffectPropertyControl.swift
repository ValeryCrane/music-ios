import Foundation
import UIKit
import CoreMotion

extension EffectPropertyControl {
    enum Constants {
        static let buttonWidth: CGFloat = 24
        static let elementSpacing: CGFloat = 24
        static let controlHeight: CGFloat = 36
        static let noiseEasing: Double = 15
        static let accelerationMultiplier: Double = 2
    }
}

final class EffectPropertyControl: UIControl {
    let type: EffectPropertyType
    private(set) var value: Float
    var isAcceletometerEnabled: Bool = false {
        didSet {
            updateAccelerometerButtonState()
        }
    }

    private let motionManager = CMMotionManager()
    private var smoothXAcceleration: Double = 0

    private let stackView = UIStackView()
    private let slider = UISlider()
    private let accelerometerButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = .init(top: 0, leading: 4, bottom: 0, trailing: 4)
        return UIButton(configuration: configuration)
    }()

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

        motionManager.startAccelerometerUpdates()
        if let accelerometerData = motionManager.accelerometerData {
            smoothXAcceleration = accelerometerData.acceleration.x
        }
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
        slider.addTarget(self, action: #selector(onSliderChangeValue(_:)), for: .valueChanged)

        accelerometerButton.tintColor = .imp.primary
        accelerometerButton.layer.cornerRadius = .defaultCornerRadius
        accelerometerButton.setImage(.init(systemName: "rectangle.portrait.rotate"), for: .normal)
        accelerometerButton.addTarget(self, action: #selector(onAccelerometerButtonTapped(_:)), for: .touchUpInside)

        let displayLink = CADisplayLink(target: self, selector: #selector(onDisplayLinkTriggered(_:)))
        displayLink.add(to: .current, forMode: .common)
    }
    
    private func layout() {
        let stackView = UIStackView(arrangedSubviews: [slider, accelerometerButton])
        stackView.axis = .horizontal
        stackView.spacing = Constants.elementSpacing
        stackView.alignment = .center

        stackView.translatesAutoresizingMaskIntoConstraints = false
        accelerometerButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: Constants.controlHeight)
        ])
    }
    
    @objc
    private func onSliderChangeValue(_ sender: UISlider) {
        value = sender.value
        sendActions(for: .valueChanged)
    }

    @objc
    private func onDisplayLinkTriggered(_ sender: CADisplayLink) {
        if isAcceletometerEnabled {
            if let xAcceleration = motionManager.accelerometerData?.acceleration.x {
                smoothXAcceleration += (xAcceleration - smoothXAcceleration) / Constants.noiseEasing
            }

            let expandedGravityValue = min(max(smoothXAcceleration * Constants.accelerationMultiplier, -1), 1)
            slider.value = slider.minimumValue + (slider.maximumValue - slider.minimumValue) * Float(expandedGravityValue + 1) / 2
            onSliderChangeValue(slider)
        }
    }

    @objc
    private func onAccelerometerButtonTapped(_ sender: UIButton) {
        isAcceletometerEnabled.toggle()
        sendActions(for: .primaryActionTriggered)
    }

    private func updateAccelerometerButtonState() {
        if isAcceletometerEnabled {
            accelerometerButton.tintColor = .imp.backgroundColor
            accelerometerButton.backgroundColor = .imp.primary
        } else {
            accelerometerButton.tintColor = .imp.primary
            accelerometerButton.backgroundColor = .clear
        }
    }
}
