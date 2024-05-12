import Foundation
import UIKit

protocol ChooseMelodyViewModelInput {
    func loadMelodies()
    func getMelodies() -> [MelodyMiniature]?
    func getStates() -> [ChooseMelodyTableViewCell.State]
    func playButtonTapped(atIndex index: Int)
    func melodyChosen(atIndex index: Int)
    func cancelButtonTapped()
    func createButtonTapped()
    func viewDidDisappear()
}

protocol ChooseMelodyViewModelOutput: UIViewController {
    func showLoader()
    func setButtonsState(isEnabled: Bool)
    func updateMelodies()
    func updateState(atIndex index: Int, state: ChooseMelodyTableViewCell.State)
}

final class ChooseMelodyViewModel {
    weak var view: ChooseMelodyViewModelOutput?

    private let melodyCreationHandler: (ChooseMelodyResult) async -> Void
    private let closeHandler: () -> Void

    private let melodiesGet = Requests.MelodiesGet()
    private let melodyGet = Requests.MelodyGet()

    private let metronome: Metronome
    private let audioEngineManager = AudioEngineManager()

    private var melodies: [MelodyMiniature]?
    private var melodyStates: [ChooseMelodyTableViewCell.State] = []

    private var indexOfCurrentMelody: Int?
    private var loadMelodyTask: Task<Void, Error>?
    private var melodyManager: MelodyManager?

    private var createMelodyAlertAction: UIAlertAction?
    private var didReturnMelody: Bool = false

    init(
        metronome: Metronome,
        melodyCreationHandler: @escaping (ChooseMelodyResult) async -> Void,
        closeHandler: @escaping () -> Void
    ) {
        self.metronome = metronome
        self.melodyCreationHandler = melodyCreationHandler
        self.closeHandler = closeHandler
    }

    private func playMelody(atIndex index: Int) async throws {
        guard let melodyId = melodies?[index].id else { return }

        indexOfCurrentMelody = index
        await MainActor.run {
            view?.updateState(atIndex: index, state: .loading)
        }

        let melodyGetResponse = try await melodyGet.run(with: .init(id: melodyId))
        let melody = try MutableMelody(.init(from: melodyGetResponse))

        try Task.checkCancellation()

        let melodyManager = try await MelodyManager(melody: melody, metronome: metronome)
        self.melodyManager = melodyManager

        audioEngineManager.addNodeToMainMixer(melodyManager.outputNode)
        metronome.play()

        await MainActor.run {
            view?.updateState(atIndex: index, state: .playing)
        }
    }

    private func stopCurrentMelody() {
        guard let index = indexOfCurrentMelody else { return }

        metronome.reset()
        loadMelodyTask?.cancel()
        indexOfCurrentMelody = nil
        melodyManager = nil

        DispatchQueue.main.async {
            self.view?.updateState(atIndex: index, state: .paused)
        }
    }

    private func showCreateMelodyAlert() {
        let alertViewController = UIAlertController(title: "Введите название мелодии", message: nil, preferredStyle: .alert)
        alertViewController.addTextField { [weak self] textField in
            textField.placeholder = "Гитарное соло"
            if let self = self {
                textField.addTarget(self, action: #selector(self.onAlertTextFieldEdited(_:)), for: .editingChanged)
            }
        }

        let createMelodyAlertAction = UIAlertAction(
            title: "Создать",
            style: .default
        ) { [weak self] _ in
            if let text = alertViewController.textFields?.first?.text, !text.isEmpty {
                self?.createEmptyMelody(withName: text)
            }
        }

        alertViewController.addAction(.init(title: "Отмена", style: .cancel))
        alertViewController.addAction(createMelodyAlertAction)
        createMelodyAlertAction.isEnabled = false
        self.createMelodyAlertAction = createMelodyAlertAction

        view?.present(alertViewController, animated: true)
    }

    private func createEmptyMelody(withName name: String) {
        let melody = MutableMelody(.empty(withName: name))

        view?.showLoader()
        view?.setButtonsState(isEnabled: false)
        view?.isModalInPresentation = true
        Task {
            await returnMelody(melody: melody, userCreated: true)
        }
    }

    private func returnMelody(melody: MutableMelody, userCreated: Bool) async {
        Task {
            await melodyCreationHandler(.init(melody: melody, userCreated: userCreated))
            didReturnMelody = true
            await MainActor.run {
                view?.dismiss(animated: true)
            }
        }
    }

    @objc
    private func onAlertTextFieldEdited(_ sender: UITextField) {
        if let text = sender.text, !text.isEmpty {
            createMelodyAlertAction?.isEnabled = true
        } else {
            createMelodyAlertAction?.isEnabled = false
        }
    }
}

extension ChooseMelodyViewModel: ChooseMelodyViewModelInput {
    func loadMelodies() {
        Task {
            let melodiesGetResponse = try await melodiesGet.run(with: .init())
            melodies = melodiesGetResponse.melodies.map { .init(from: $0) }
            melodyStates = .init(repeating: .paused, count: melodiesGetResponse.melodies.count)
            await MainActor.run {
                view?.updateMelodies()
            }
        }
    }
    
    func getMelodies() -> [MelodyMiniature]? {
        melodies
    }
    
    func getStates() -> [ChooseMelodyTableViewCell.State] {
        melodyStates
    }
    
    func playButtonTapped(atIndex index: Int) {
        loadMelodyTask = Task {
            if index == indexOfCurrentMelody {
                stopCurrentMelody()
            } else {
                stopCurrentMelody()
                try await playMelody(atIndex: index)
            }
        }
    }
    
    func melodyChosen(atIndex index: Int) {
        guard let melodyId = melodies?[index].id else { return }

        view?.showLoader()
        view?.setButtonsState(isEnabled: false)
        view?.isModalInPresentation = true

        Task {
            let melodyGetResponse = try await melodyGet.run(with: .init(id: melodyId))
            let melody = try MutableMelody(.init(from: melodyGetResponse))
            await returnMelody(melody: melody, userCreated: false)
        }
    }
    
    func cancelButtonTapped() {
        view?.dismiss(animated: true)
    }
    
    func createButtonTapped() {
        showCreateMelodyAlert()
    }
    
    func viewDidDisappear() {
        closeHandler()
    }
}
