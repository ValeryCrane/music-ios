import Foundation
import UIKit

protocol CombinationViewModelInput: AnyObject {
    func getMelodies() -> [MutableMelody]
    func getSamples() -> [MutableSample]
    
    func didPressEffectsButtonOnSample(_ sample: MutableSample)
    func didPressEditButtonOnMelody(atIndex index: Int)
}

protocol CombinationViewModelOutput: UIViewController {
    
}

final class CombinationViewModel {
    
    weak var view: CombinationViewModelOutput?
    
    private let combination: MutableCombination
    
    init(combination: MutableCombination) {
        self.combination = combination
    }
}

extension CombinationViewModel: CombinationViewModelInput {
    func didPressEditButtonOnMelody(atIndex index: Int) {
        // TODO
    }
    
    func didPressEffectsButtonOnSample(_ sample: MutableSample) {
        // TODO
    }
    
    func getSamples() -> [MutableSample] {
        combination.samples
    }
    
    func getMelodies() -> [MutableMelody] {
        combination.melodies
    }
}
