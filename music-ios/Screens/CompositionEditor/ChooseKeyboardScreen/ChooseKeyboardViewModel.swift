import Foundation
import UIKit

protocol ChooseKeyboardViewModelInput {
    func loadKeyboards()
    func getCurrentKeyboard() -> KeyboardMiniature
    func getKeyboards() -> [KeyboardMiniature]?
    func getStates() -> [ChooseKeyboardTableViewCell.State]
    func onPlayButtonPressed(atIndex index: Int)
    func onKeyboardChoosen(atIndex index: Int)
    func onCancelButtonPressed()
}

protocol ChooseKeyboardViewModelOutput: UIViewController {
    func updateKeyboards()
    func updateState(atIndex index: Int, state: ChooseKeyboardTableViewCell.State)
}

final class ChooseKeyboardViewModel {
    weak var view: ChooseKeyboardViewModelOutput?

    private let currentKeyboard: KeyboardMiniature
    private let completion: (KeyboardMiniature?) -> Void

    private let keyboardsGet = Requests.KeyboardsGet()
    private let keyboardPreviewManager = KeyboardPreviewManager()
    private let audioEngineManager = AudioEngineManager()

    private var keyboards: [KeyboardMiniature]?
    private var keyboardStates: [ChooseKeyboardTableViewCell.State] = []
    private var playTask: Task<Void, Error>?

    init(
        currentKeyboard: KeyboardMiniature,
        completion: @escaping (KeyboardMiniature?) -> Void
    ) {
        self.currentKeyboard = currentKeyboard
        self.completion = completion
        audioEngineManager.addNodeToMainMixer(keyboardPreviewManager.outputNode)
    }

    private func showConfirmationDialog(keyboard: KeyboardMiniature) {
        let alertController = UIAlertController(
            title: "Очистить мелодию?",
            message: "Количество клавиш на выбранной клавиатуре не совпадает с текущим количеством клавиш. При смене клавиатуры мелодия будет очищена.",
            preferredStyle: .alert
        )
        alertController.addAction(.init(title: "Отмена", style: .cancel))
        alertController.addAction(.init(title: "Очистить и сменить клавиатуру", style: .destructive, handler: { [weak self] _ in
            self?.completion(keyboard)
            self?.view?.dismiss(animated: true)
        }))

        view?.present(alertController, animated: true)
    }
}

extension ChooseKeyboardViewModel: ChooseKeyboardViewModelInput {
    @MainActor
    func loadKeyboards() {
        Task {
            let keyboardsGetResponse = try await keyboardsGet.run(with: .init())
            keyboards = keyboardsGetResponse.keyboards.map { .init(from: $0) }
            keyboardStates = .init(repeating: .paused, count: keyboardsGetResponse.keyboards.count)
            await MainActor.run {
                view?.updateKeyboards()
            }
        }
    }

    func getCurrentKeyboard() -> KeyboardMiniature {
        currentKeyboard
    }

    func getKeyboards() -> [KeyboardMiniature]? {
        keyboards
    }

    func getStates() -> [ChooseKeyboardTableViewCell.State] {
        keyboardStates
    }

    func onPlayButtonPressed(atIndex index: Int) {
        playTask?.cancel()
        playTask = Task {
            view?.updateState(atIndex: index, state: .loading)
            try await withTaskCancellationHandler {
                if let keyboards = keyboards {
                    try await keyboardPreviewManager.preview(keyboardId: keyboards[index].id)
                    await MainActor.run {
                        view?.updateState(atIndex: index, state: .paused)
                    }
                }
            } onCancel: {
                DispatchQueue.main.async { [weak self] in
                    self?.view?.updateState(atIndex: index, state: .paused)
                }
            }
        }
    }

    func onKeyboardChoosen(atIndex index: Int) {
        guard let keyboards = keyboards else { return }

        if keyboards[index].numberOfKeys != currentKeyboard.numberOfKeys {
            showConfirmationDialog(keyboard: keyboards[index])
        } else if keyboards[index].id != currentKeyboard.id {
            completion(keyboards[index])
            view?.dismiss(animated: true)
        } else {
            completion(nil)
            view?.dismiss(animated: true)
        }
    }

    func onCancelButtonPressed() {
        completion(nil)
        view?.dismiss(animated: true)
    }
}
