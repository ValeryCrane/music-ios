import Foundation
import UIKit

protocol CompositionViewModelInput: AnyObject { 
    func getCombinations() -> [MutableCombination]
    func getIsFavourite() -> Bool
    
    func onCompositionsParametersButtonPressed()
    func onFavouriteButtonPressed()
    func createFork(name: String)
}

protocol CompositionViewModelOutput: UIViewController { }

final class CompositionViewModel {
    
    private var composition: MutableComposition
    
    init(composition: Composition) {
        self.composition = .init(composition)
    }
}

extension CompositionViewModel: CompositionViewModelInput {
    func onCompositionsParametersButtonPressed() {
        // TODO
    }
    
    func onFavouriteButtonPressed() {
        // TODO
    }
    
    func createFork(name: String) {
        // TODO
    }
    
    func getCombinations() -> [MutableCombination] {
        composition.combinations
    }
    
    func getIsFavourite() -> Bool {
        composition.isFavourite
    }
}
