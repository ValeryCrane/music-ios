import Foundation
import UIKit

protocol RecordSampleViewModelInput {
    func startRecording(beats: Int)
    func pauseRecording()
    func stopRecording()
    func playRecording()
    func clearRecording()
    func saveRecording(name: String)
    
    func onCloseButtonPressed()
}

protocol RecordSampleViewModelOutput: UIViewController {
    
}

final class RecordSampleViewModel {
    weak var view: RecordSampleViewModelOutput?
}

extension RecordSampleViewModel: RecordSampleViewModelInput {
    func startRecording(beats: Int) {
        // TODO
    }
    
    func pauseRecording() {
        // TODO
    }
    
    func stopRecording() {
        // TODO
    }
    
    func playRecording() {
        // TODO
    }
    
    func clearRecording() {
        // TODO
    }
    
    func saveRecording(name: String) {
        // TODO
    }
    
    func onCloseButtonPressed() {
        view?.dismiss(animated: true)
    }
    
    
}
