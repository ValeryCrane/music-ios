import Foundation
import UIKit

protocol ChooseMelodyViewModelInput {
    func getMelodies() -> [MelodyMiniature]?
    func getStates() -> [ChooseMelodyTableViewCell.State]
    func loadMelodies()
    func onPlayButtonPressed(atIndex index: Int)
    func onCancelButtonPressed()
    func onCreateButtonPressed()
}

protocol ChooseMelodyViewModelOutput: UIViewController {
    func updateMelodies()
    func updateState(atIndex index: Int, state: ChooseMelodyTableViewCell.State)
}

@MainActor
final class ChooseMelodyViewModel {
    weak var view: ChooseMelodyViewModelOutput?
    
    private var melodies: [MelodyMiniature]?
    private var melodyStates: [ChooseMelodyTableViewCell.State] = []
    
    private let melodiesGet = Requests.MelodiesGet()
}

extension ChooseMelodyViewModel: ChooseMelodyViewModelInput {
    func loadMelodies() {
        Task {
            let melodiesGetResponse = try await melodiesGet.run(with: .init())
            melodies = melodiesGetResponse.melodies.map { .init(from: $0) }
            melodyStates = .init(repeating: .paused, count: melodiesGetResponse.melodies.count)
            view?.updateMelodies()
        }
    }
    
    func getMelodies() -> [MelodyMiniature]? {
        melodies
    }
    
    func getStates() -> [ChooseMelodyTableViewCell.State] {
        melodyStates
    }
    
    func onPlayButtonPressed(atIndex index: Int) {
        // TODO
    }
    
    func onCancelButtonPressed() {
        view?.dismiss(animated: true)
    }
    
    func onCreateButtonPressed() {
        // TODO
    }
}
