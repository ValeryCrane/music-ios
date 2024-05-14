import Foundation
import UIKit

protocol CompositionNavigationControllerInput: UINavigationController {
    func showSaveButton()
    func hideSaveButton()
}

protocol CompositionNavigationControllerOutput: AnyObject {
    func saveButtonTapped()
}

final class CompositionNavigationController: UINavigationController {
    weak var output: CompositionNavigationControllerOutput?

    private let recordToolbar = RecordToolbarView()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureRecordToolbar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for viewController in viewControllers {
            viewController.additionalSafeAreaInsets = .init(
                top: 0, left: 0, bottom: recordToolbar.frame.height - view.safeAreaInsets.bottom, right: 0
            )
        }
    }

    private func configureRecordToolbar() {
        recordToolbar.delegate = self
        recordToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recordToolbar)
        view.bringSubviewToFront(recordToolbar)

        NSLayoutConstraint.activate([
            recordToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recordToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recordToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension CompositionNavigationController: RecordToolbarViewDelegate {
    func recordToolbarView(didChangeIsMicMuted isMicMuted: Bool) {
        // TODO.
    }
    
    func recordToolbarViewDidStartRecording() {
        // TODO.
    }
    
    func recordToolbarViewDidEndRecording() {
        // TODO.
    }
    
    func saveButtonTapped() {
        output?.saveButtonTapped()
    }
}

extension CompositionNavigationController: CompositionNavigationControllerInput {
    func showSaveButton() {
        recordToolbar.showSaveCompositionButton()
    }
    
    func hideSaveButton() {
        recordToolbar.hideSaveCompositionButton()
    }
}
