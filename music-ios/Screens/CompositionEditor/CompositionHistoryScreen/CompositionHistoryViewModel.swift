import Foundation
import UIKit

protocol CompositionHistoryViewModelInput {
    func loadHistory()
    func getHistoryEvents() -> [CompositionHistoryEvent]?
}

protocol CompositionHistoryViewModelOutput: UIViewController {
    func updateHistoryEvents()
}

final class CompositionHistoryViewModel {
    weak var view: CompositionHistoryViewModelOutput?

    private let composition: MutableComposition
    private let compositionParametersManager: CompositionParametersManager

    private var historyEvents: [CompositionHistoryEvent]?

    init(composition: MutableComposition, compositionParametersManager: CompositionParametersManager) {
        self.composition = composition
        self.compositionParametersManager = compositionParametersManager
    }
}

extension CompositionHistoryViewModel: CompositionHistoryViewModelInput {
    func loadHistory() {
        Task {
            historyEvents = try await compositionParametersManager.getCompositionHistory(
                compositionId: composition.id
            )

            await MainActor.run {
                view?.updateHistoryEvents()
            }
        }
    }
    
    func getHistoryEvents() -> [CompositionHistoryEvent]? {
        historyEvents
    }
}
