import Foundation
import UIKit

// MARK: - EditMelodyViewModelDelegate

protocol EditMelodyViewModelDelegate: AnyObject {
    func editMelodyViewModelStartedEditing(_ editMelodyViewModel: EditMelodyViewModel)
    func editMelodyViewModelEndedEditing(_ editMelodyViewModel: EditMelodyViewModel)
}

// MARK: - EditMelodyViewModelInput

protocol EditMelodyViewModelInput {
    func onPlayButtonTapped()
    func onEffectsButtonTapped()
    func onChooseKeyboardButtonTapped()
    func onCloseButtonTapped()
    func onPedalButtonTapped()
    func onDoneButtonTapped()

    func getInitialMeasures() -> Int
    func getInitialKeyboardSize() -> Int
    func getInitialPedalState() -> Bool
    func getInitialNotes() -> [NoteViewModel]

    func getMaxMeasures() -> Int
    func setMeasures(_ measures: Int)

    func createNote(noteViewModel: NoteViewModel)
    func deleteNote(noteViewModel: NoteViewModel)

    func getPlayIndicatorPosition() -> Double

    func viewWillAppear()
    func viewWillDisappear()
}

// MARK: - EditMelodyViewModelOutput

protocol EditMelodyViewModelOutput: UIViewController {
    func loadingStarted()
    func loadingCompleted()

    func updateMeasures(_ measures: Int)
    func updateKeyboardSize(_ keyboardSize: Int)
    func updatePlayButtonState(isPlaying: Bool)
    func updatePedalButtonState(isActive: Bool)

    func createNote(noteViewModel: NoteViewModel)
    func deleteNote(noteViewModel: NoteViewModel)

    func startPlayIndicator()
    func removePlayIndicator()
    func showPlayAnimation(note: NoteViewModel)
}

// MARK: - EditMelodyViewModel

extension EditMelodyViewModel {
    private enum Constants {
        static let maxMeasures: Int = 8
        static let melodyVolumeDuringChoosingKeyboard: Float = 0.25
    }
}

final class EditMelodyViewModel {
    weak var view: EditMelodyViewModelOutput?
    weak var delegate: EditMelodyViewModelDelegate?

    // MARK: Private properties

    private let metronome: Metronome
    private let effectsManager: EffectsManager
    private var melodyManager: MelodyManager
    private var noteViewModelMapping = ObjectMapper<NoteViewModel, MutableNote>()

    // MARK: Init

    init(metronome: Metronome, melodyManager: MelodyManager, effectsManager: EffectsManager) {
        self.metronome = metronome
        self.melodyManager = melodyManager
        self.effectsManager = effectsManager
        metronome.addListener(self)
        melodyManager.delegate = self
    }

    // MARK: Private functions

    private func updateKeyboard(keyboardMiniature: KeyboardMiniature) {
        Task {
            await MainActor.run {
                view?.loadingStarted()
            }
            try await melodyManager.setKeyboard(
                keyboardId: keyboardMiniature.id
            )
            await MainActor.run {
                view?.updateKeyboardSize(melodyManager.keyboardSize)
                view?.loadingCompleted()
            }
        }
    }

    private func showChangeMeasuresConfirmationDialog(measures: Int) {
        let alertController = UIAlertController(
            title: "Удалить ноты?",
            message: "Выбранное количество тактов меньше текущего. Ноты, выходящие за пределы продолжительности мелодии, будут удалены.",
            preferredStyle: .alert
        )

        alertController.addAction(.init(title: "Отмена", style: .cancel))

        alertController.addAction(.init(title: "Хорошо", style: .destructive, handler: { [weak self] _ in
            self?.melodyManager.setMeasures(measures)
            self?.view?.updateMeasures(measures)
        }))

        view?.present(alertController, animated: true)
    }
}

// MARK: - EditMelodyViewModelInput

extension EditMelodyViewModel: EditMelodyViewModelInput {
    func onPlayButtonTapped() {
        if metronome.isPlaying {
            metronome.reset()
        } else {
            metronome.play()
        }
    }
    
    func onEffectsButtonTapped() {
        let effectsEditor = EffectEditor(effectsManager: effectsManager)
        let viewController = effectsEditor.getViewController()
        view?.present(viewController, animated: true)
    }
    
    func onChooseKeyboardButtonTapped() {
        melodyManager.setVolume(Constants.melodyVolumeDuringChoosingKeyboard)

        let chooseKeyboardCompletion: (KeyboardMiniature?) -> Void = { [weak self] keyboardMiniature in
            self?.melodyManager.setVolume(1)
            if let keyboardMiniature = keyboardMiniature {
                self?.updateKeyboard(keyboardMiniature: keyboardMiniature)
            }
        }

        let chooseKeyboard = ChooseKeyboard(
            currentKeyboard: melodyManager.keyboardMiniature,
            completion: chooseKeyboardCompletion
        )

        view?.present(chooseKeyboard.getViewController(), animated: true)
    }
    
    func onCloseButtonTapped() {
        view?.dismiss(animated: true)
    }
    
    func onPedalButtonTapped() {
        melodyManager.setPedalState(!melodyManager.isPedalActive)
        view?.updatePedalButtonState(isActive: melodyManager.isPedalActive)
    }

    func onDoneButtonTapped() {
        view?.dismiss(animated: true)
    }

    func getInitialMeasures() -> Int {
        melodyManager.measures
    }
    
    func getInitialKeyboardSize() -> Int {
        melodyManager.keyboardSize
    }
    
    func getInitialPedalState() -> Bool {
        melodyManager.isPedalActive
    }

    func getInitialNotes() -> [NoteViewModel] {
        melodyManager.notes.map { note in
            let noteViewModel = NoteViewModel(key: note.keyNumber, start: note.start, end: note.end)
            noteViewModelMapping[note] = noteViewModel
            return noteViewModel
        }
    }

    func getMaxMeasures() -> Int {
        Constants.maxMeasures
    }

    func setMeasures(_ measures: Int) {
        if melodyManager.willDeleteNotesSettingMeasures(measures) {
            showChangeMeasuresConfirmationDialog(measures: measures)
        } else {
            melodyManager.setMeasures(measures)
            view?.updateMeasures(measures)
        }
    }
    
    func createNote(noteViewModel: NoteViewModel) {
        let note = MutableNote(.init(keyNumber: noteViewModel.key, start: noteViewModel.start, end: noteViewModel.end))
        noteViewModelMapping[noteViewModel] = note

        self.melodyManager.addNote(note)
    }
    
    func deleteNote(noteViewModel: NoteViewModel) {
        if let note = noteViewModelMapping[noteViewModel] {
            noteViewModelMapping[noteViewModel] = nil
            melodyManager.deleteNote(note)
        }
    }
    
    func getPlayIndicatorPosition() -> Double {
        if let currentBeat = metronome.getBeat(ofHostTime: mach_absolute_time()) {
            let beats = melodyManager.measures * .beatsInMeasure
            let remainderBeat = currentBeat - floor(currentBeat / Double(beats)) * Double(beats)
            return remainderBeat / Double(beats)
        } else {
            return 0
        }
    }

    func viewWillAppear() {
        delegate?.editMelodyViewModelStartedEditing(self)
    }

    func viewWillDisappear() {
        delegate?.editMelodyViewModelEndedEditing(self)
    }
}

// MARK: - MelodyManagerDelegate

extension EditMelodyViewModel: MelodyManagerDelegate {
    func melodyManager(_ melodyManager: MelodyManager, didDeleteNote note: MutableNote) {
        if let noteViewModel = noteViewModelMapping[note] {
            noteViewModelMapping[note] = nil
            DispatchQueue.main.async {
                self.view?.deleteNote(noteViewModel: noteViewModel)
            }
        }
    }
}

// MARK: - MetronomeListener

extension EditMelodyViewModel: MetronomeListener {
    func metronome(_ metronome: Metronome, didStartPlayingAtBeat beat: Double) {
        DispatchQueue.main.async {
            self.view?.startPlayIndicator()
            self.view?.updatePlayButtonState(isPlaying: true)
        }
    }
    
    func metronome(_ metronome: Metronome, didStopPlayingAtBeat beat: Double) {
        DispatchQueue.main.async {
            self.view?.removePlayIndicator()
            self.view?.updatePlayButtonState(isPlaying: false)
        }
    }

    func metronome(_ metronome: Metronome, didUpdateBPM bpm: Double) {
        // TODO.
    }
}
