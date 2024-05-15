import Foundation
import UIKit

protocol ChooseSampleViewModelInput {
    func getSamples() -> [SampleMiniature]?
    func getStates() -> [ChooseSampleTableViewCell.State]
    func loadSamples()
    func onPlayButtonPressed(atIndex index: Int)
    func onCancelButtonPressed()
    func onCreateButtonPressed()
}

protocol ChooseSampleViewModelOutput: UIViewController {
    func updateSamples()
    func updateState(atIndex index: Int, state: ChooseSampleTableViewCell.State)
}

final class ChooseSampleViewModel {
    weak var view: ChooseSampleViewModelOutput?

    private let sampleCreationHandler: (MutableSample) async -> Void
    private let recordSampleHandler: () -> Void

    private var samples: [SampleMiniature]?
    private var sampleStates: [ChooseSampleTableViewCell.State] = []

    private let samplesGet = Requests.SamplesGet()

    init(sampleCreationHandler: @escaping (MutableSample) async -> Void, recordSampleHandler: @escaping () -> Void) {
        self.sampleCreationHandler = sampleCreationHandler
        self.recordSampleHandler = recordSampleHandler
    }
}

extension ChooseSampleViewModel: ChooseSampleViewModelInput {
    func loadSamples() {
        Task {
            let samplesGetResponse = try await samplesGet.run(with: .init())
            samples = samplesGetResponse.samples.map { .init(from: $0) }
            sampleStates = .init(repeating: .paused, count: samplesGetResponse.samples.count)
            await MainActor.run {
                view?.updateSamples()
            }
        }
    }
    
    func getSamples() -> [SampleMiniature]? {
        samples
    }
    
    func getStates() -> [ChooseSampleTableViewCell.State] {
        sampleStates
    }
    
    func onPlayButtonPressed(atIndex index: Int) {
        // TODO
    }
    
    func onCancelButtonPressed() {
        view?.dismiss(animated: true)
    }
    
    func onCreateButtonPressed() {
        view?.dismiss(animated: true, completion: recordSampleHandler)
    }
}
