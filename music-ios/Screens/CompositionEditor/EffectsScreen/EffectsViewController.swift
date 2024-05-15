import Foundation
import UIKit

extension EffectsViewController {
    private enum Constants {
        static let elementSpacing: CGFloat = 16
        static let verticalOffsets: CGFloat = 16
        static let horizontalOffsets: CGFloat = 16
    }
}

final class EffectsViewController: UIViewController {
    private let viewModel: EffectsViewModelInput

    override var preferredContentSize: CGSize {
        get {
            let arrangedSubviewsHeight = stackView.arrangedSubviews.reduce(CGFloat.zero, { partialResult, subview in
                partialResult + subview.intrinsicContentSize.height
            })
            let spacingHeight = CGFloat(stackView.arrangedSubviews.count - 1) * Constants.elementSpacing
            let offsetsHeight = 2 * Constants.verticalOffsets + view.safeAreaInsets.bottom
            return .init(
                width: UIView.noIntrinsicMetric,
                height: arrangedSubviewsHeight + spacingHeight + offsetsHeight
            )
        }
        set { }
    }

    private let stackView = UIStackView()

    init(viewModel: EffectsViewModelInput) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .imp.backgroundColor
        configure()
        layout()
    }
    
    private func configure() {
        stackView.axis = .vertical
        stackView.spacing = Constants.elementSpacing

        for effectType in EffectType.allCases {
            let effectControl = EffectControl(
                type: effectType,
                initialProperties: effectType.propertyTypes.reduce(
                    into: [EffectPropertyType: Float]()
                ) { partialResult, propertyType in
                    partialResult[propertyType] = viewModel.getValueOfPropertyType(propertyType)
                }
            )

            effectControl.delegate = self
            stackView.addArrangedSubview(effectControl)
        }
    }
    
    private func layout() {
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.verticalOffsets),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalOffsets),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalOffsets)
        ])
    }
}

extension EffectsViewController: EffectControlDelegate {
    func effectControl(
        _ effectControl: EffectControl,
        didChangeValue value: Float,
        ofPropertyType propertyType: EffectPropertyType
    ) {
        viewModel.setValue(value, ofPropertyType: propertyType)
    }

    func effectControlDidEnableAccelerometer(_ effectControl: EffectControl) {
        for subview in stackView.arrangedSubviews {
            if subview !== effectControl, let effectControl = subview as? EffectControl {
                effectControl.disableAccelerometer()
            }
        }
    }
}
