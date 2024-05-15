import Foundation
import AVFoundation

extension RecordSampleManager {
    private enum Constants {
        static let recordBufferSize: AVAudioFrameCount = 512
    }
}

final class RecordSampleManager {
    private let audioEngineManager = AudioEngineManager()
    private let playerNode = AVAudioPlayerNode()

    private let unconvertedFileURL = FileManager.default.temporaryDirectory.appending(path: "unconverted.caf")
    private let convertedFileURL = FileManager.default.temporaryDirectory.appending(path: "converted.wav")

    private let sampleCreate = Requests.SampleCreate()

    func startRecording() throws {
        clear()
        
        let unconvertedFile = try AVAudioFile(forWriting: unconvertedFileURL, settings: AudioEngineManager.inputNodeFormat.settings)
        audioEngineManager.recordSoundFromInput(bufferSize: Constants.recordBufferSize) { buffer, time in
            do {
                try unconvertedFile.write(from: buffer)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func endRecording(cutToDuration duration: Double) throws -> URL {
        audioEngineManager.stopInputSoundRecording()
        try convertToWav(inputURL: unconvertedFileURL, outputURL: convertedFileURL, cutToDuration: duration)
        return convertedFileURL
    }

    func uploadSampleToServer(name: String, beats: Int) async throws -> Int {
        let response = try await sampleCreate.run(with: .init(sampleURL: convertedFileURL, name: name, beats: beats))
        return response.id
    }

    func clear() {
        try? FileManager.default.removeItem(at: unconvertedFileURL)
        try? FileManager.default.removeItem(at: convertedFileURL)
    }

    private func convertToWav(inputURL: URL, outputURL: URL, cutToDuration duration: Double) throws {
        let inputBuffer = try AVAudioPCMBuffer(from: inputURL)
        guard let outputFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2) else {
            throw RuntimeError("Counldn't construct output format")
        }

        let outputFile = try AVAudioFile(
            forWriting: outputURL,
            settings: outputFormat.settings,
            commonFormat: outputFormat.commonFormat,
            interleaved: false
        )

        let outputCapacity = AVAudioFrameCount(duration * outputFormat.sampleRate)
        let converter = AVAudioConverter(from: inputBuffer.format, to: outputFormat)
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFile.processingFormat, frameCapacity: outputCapacity) else {
            throw RuntimeError("Couldn't construct audio buffer")
        }

        converter?.convert(to: outputBuffer, error: nil) { (numPackets, status) in
            status.pointee = .haveData
            return inputBuffer
        }

        try outputFile.write(from: outputBuffer)
    }
}
