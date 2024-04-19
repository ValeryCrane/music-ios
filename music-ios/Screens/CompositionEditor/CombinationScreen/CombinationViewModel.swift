import Foundation
import UIKit

protocol CombinationViewModelInput: AnyObject {
    func getMelodies() -> [MutableMelody]
    func getSamples() -> [MutableSample]
}

protocol CombinationViewModelOutput: UIViewController {
    
}

final class CombinationViewModel {
    
    private let combination: MutableCombination
    
    init(combination: MutableCombination) {
        self.combination = combination
    }
}

extension CombinationViewModel: CombinationViewModelInput {
    func getSamples() -> [MutableSample] {
        combination.samples
    }
    
    func getMelodies() -> [MutableMelody] {
        combination.melodies
    }
}
