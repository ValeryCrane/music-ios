import Foundation
import UIKit

final class RecordSample {
    private let bpm: Double
    private let recordSampleManager = RecordSampleManager()
    private let createSampleHandler: (Sample) async -> Void

    init(bpm: Double, createSampleHandler: @escaping (Sample) async -> Void) {
        self.bpm = bpm
        self.createSampleHandler = createSampleHandler
    }

    func getViewController() -> UIViewController {
        let viewModel = RecordSampleViewModel(bpm: bpm, recordSampleManager: recordSampleManager, createSampleHandler: createSampleHandler)
        let viewController = RecordSampleViewController(viewModel: viewModel)
        viewModel.view = viewController
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
}
