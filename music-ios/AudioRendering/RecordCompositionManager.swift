import Foundation
import AVFoundation

extension RecordCompositionManager {
    private enum Constants {
        static let recordBufferSize: AVAudioFrameCount = 512
    }
}

final class RecordCompositionManager {

    private let audioEngineManager = AudioEngineManager()
    private let recordingURL = FileManager.default.temporaryDirectory.appending(path: "recording.caf")

    func startRecording() throws {
        clear()

        let recordingFile = try AVAudioFile(forWriting: recordingURL, settings: AudioEngineManager.outputNodeFormat.settings)
        audioEngineManager.recordSoundFromOutput(bufferSize: Constants.recordBufferSize) { buffer, time in
            do {
                try recordingFile.write(from: buffer)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func stopRecording() -> URL {
        audioEngineManager.stopOutputSoundRecording()
        return recordingURL
    }

    private func clear() {
        try? FileManager.default.removeItem(at: recordingURL)
    }
}
