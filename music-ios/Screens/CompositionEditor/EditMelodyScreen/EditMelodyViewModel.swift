import Foundation
import UIKit

protocol EditMelodyViewModelInput {
    var isPlaying: Bool { get }
    
    func getKeyboardSize() -> Int
    func getKeySequence() -> [Int?]
    func getResolution() -> Int
    func getNumberOfBeats() -> Int
    func setResolution(_ resolution: Int)
    func setNumberOfBeats(_ numberOfBeats: Int)
    func play()
    func stop()
    func onCloseButtonPressed()
}

protocol EditMelodyViewModelOutput: UIViewController {
    
}

final class EditMelodyViewModel {
    weak var view: EditMelodyViewModelOutput?
    
    private(set) var isPlaying = false
    
    private let melody: MutableMelody
    private var keyboardSampleIds: [Int]
    
    init(melody: MutableMelody, keyboardSampleIds: [Int]) {
        self.melody = melody
        self.keyboardSampleIds = keyboardSampleIds
    }
}

extension EditMelodyViewModel: EditMelodyViewModelInput {
    func play() {
        isPlaying = true
    }
    
    func stop() {
        isPlaying = false
    }
    
    
    func getKeyboardSize() -> Int {
        keyboardSampleIds.count
    }
    
    func getKeySequence() -> [Int?] {
        melody.keys
    }
    
    func getResolution() -> Int {
        melody.resolution
    }
    
    func getNumberOfBeats() -> Int {
        melody.keys.count / melody.resolution
    }
    
    func setResolution(_ resolution: Int) {
        // TODO.
    }
    
    func setNumberOfBeats(_ numberOfBeats: Int) {
        // TODO.
    }
    
    func onCloseButtonPressed() {
        view?.dismiss(animated: true)
    }
}
