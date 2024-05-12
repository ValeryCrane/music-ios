import Foundation
import UIKit

final class ChooseMelody {

    private let metronomeBPM: Double
    private let melodyCreationHandler: (ChooseMelodyResult) async -> Void
    private let closeHandler: () -> Void

    init(
        metronomeBPM: Double,
        melodyCreationHandler: @escaping (ChooseMelodyResult) async -> Void,
        closeHandler: @escaping () -> Void
    ) {
        self.metronomeBPM = metronomeBPM
        self.melodyCreationHandler = melodyCreationHandler
        self.closeHandler = closeHandler
    }

    func getViewController() -> UIViewController {
        let viewModel = ChooseMelodyViewModel(
            metronome: .init(bpm: metronomeBPM),
            melodyCreationHandler: melodyCreationHandler,
            closeHandler: closeHandler
        )

        let viewController = ChooseMelodyViewController(viewModel: viewModel)
        viewModel.view = viewController
        return UINavigationController(rootViewController: viewController)
    }
}
