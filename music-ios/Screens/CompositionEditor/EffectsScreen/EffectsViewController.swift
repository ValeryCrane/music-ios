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
    
    private let effects: [MutableEffect]
    private let stackView = UIStackView()
    
    init(effects: [MutableEffect]) {
        self.effects = effects
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configure()
        layout()
        title = "Эффекты"
    }
    
    private func configure() {
        stackView.axis = .vertical
        stackView.spacing = Constants.elementSpacing
        
        effects.forEach {
            stackView.addArrangedSubview(EffectControl(effect: $0))
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
