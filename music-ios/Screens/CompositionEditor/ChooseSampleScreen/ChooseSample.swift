import Foundation
import UIKit

final class ChooseSample {
    private let sampleCreationHandler: (MutableSample) async -> Void
    private let recordSampleHandler: () -> Void

    init(sampleCreationHandler: @escaping (MutableSample) async -> Void, recordSampleHandler: @escaping () -> Void) {
        self.sampleCreationHandler = sampleCreationHandler
        self.recordSampleHandler = recordSampleHandler
    }

    func getViewController() -> UIViewController {
        let viewModel = ChooseSampleViewModel(sampleCreationHandler: sampleCreationHandler, recordSampleHandler: recordSampleHandler)
        let viewController = ChooseSampleViewController(viewModel: viewModel)
        viewModel.view = viewController
        return UINavigationController(rootViewController: viewController)
    }
}
