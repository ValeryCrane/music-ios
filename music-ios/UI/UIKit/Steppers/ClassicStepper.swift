import Foundation
import UIKit

final class ClassicStepper: NiceStepper {
    private let bpmLabel = UILabel()
    
    init(value: Int, minimumValue: Int, maximumValue: Int) {
        super.init(
            value: value,
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            wrappedView: bpmLabel
        )
        
        bpmLabel.role(.title)
        bpmLabel.text = "\(value)"
        addTarget(self, action: #selector(onStepperValueChanged(_:)), for: .valueChanged)
    }

    @objc
    private func onStepperValueChanged(_ sender: NiceStepper) {
        bpmLabel.text = "\(value)"
    }
}
