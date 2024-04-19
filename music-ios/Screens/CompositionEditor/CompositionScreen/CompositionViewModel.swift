import Foundation
import UIKit

protocol CompositionViewModelInput: AnyObject { 
    func getCombinations() -> [MutableCombination]
    func getIsFavourite() -> Bool
    
    func onCompositionsParametersButtonPressed()
    func onFavouriteButtonPressed()
    func onOpenCombination(_ combination: MutableCombination)
    func createFork(name: String)
}

protocol CompositionViewModelOutput: UIViewController { }

final class CompositionViewModel {
    weak var view: CompositionViewModelOutput?
    
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
    
    func onOpenCombination(_ combination: MutableCombination) {
        let viewModel = CombinationViewModel(combination: combination)
        let combinationController = CombinationViewController(viewModel: viewModel)
        viewModel.view = combinationController
        view?.navigationController?.pushViewController(combinationController, animated: true)
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
