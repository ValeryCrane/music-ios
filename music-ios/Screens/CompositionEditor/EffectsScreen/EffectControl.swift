import Foundation
import UIKit

protocol EffectControlDelegate: AnyObject {
    func effectControl(
        _ effectControl: EffectControl,
        didChangeValue value: Float,
        ofPropertyType propertyType: EffectPropertyType
    )
}

extension EffectControl {
    private enum Constants {
        static let elementSpacing: CGFloat = 8
    }
}

final class EffectControl: UIView {
    weak var delegate: EffectControlDelegate?

    let type: EffectType
    private(set) var properties: [EffectPropertyType: Float]

    private let nameLabel = UILabel()
    private let sliderStackView = UIStackView()

    override var intrinsicContentSize: CGSize {
        .init(
            width: UIView.noIntrinsicMetric,
            height: sliderStackView.arrangedSubviews.reduce(CGFloat.zero, { partialResult, subview in
                partialResult + subview.intrinsicContentSize.height
            }) + CGFloat(sliderStackView.arrangedSubviews.count - 1) * CGFloat(Constants.elementSpacing)
        )
    }

    init(type: EffectType, initialProperties: [EffectPropertyType: Float]) {
        self.type = type
        self.properties = initialProperties

        super.init(frame: .zero)
        
        configure()
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        nameLabel.text = type.name
        nameLabel.role(.title)
        nameLabel.textColor = .secondaryLabel

        sliderStackView.axis = .vertical
        sliderStackView.spacing = Constants.elementSpacing
    }
    
    private func layout() {
        sliderStackView.addArrangedSubview(nameLabel)

        for propertyType in type.propertyTypes {
            let effectPropertyControl = EffectPropertyControl(
                type: propertyType,
                initialValue: properties[propertyType] ?? propertyType.defaultValue
            )

            effectPropertyControl.addTarget(
                self,
                action: #selector(didEffectPropertyControlChangeValue(_:)),
                for: .valueChanged
            )

            sliderStackView.addArrangedSubview(effectPropertyControl)
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

    @objc
    private func didEffectPropertyControlChangeValue(_ sender: EffectPropertyControl) {
        properties[sender.type] = sender.value
        delegate?.effectControl(self, didChangeValue: sender.value, ofPropertyType: sender.type)
    }
}
