import Foundation
import AVFoundation

enum AVAudioPCMBufferError: Error {
    case decodingError
}

extension AVAudioPCMBuffer {
    convenience init(from url: URL) throws {
        let audioFile = try AVAudioFile(forReading: url)
        let bytesPerFrame = audioFile.processingFormat.streamDescription.pointee.mBytesPerFrame
        guard audioFile.length >= 0, bytesPerFrame != 0 else {
            throw AVAudioPCMBufferError.decodingError
        }

        /*
         Согласно документации:
         The method returns nil due to the following reasons:
          - The format has zero bytes per frame.
          - The system can’t represent the buffer byte capacity as an unsigned bit-32 integer.

         Таким образом force-unwrap здесь безопасен.
         */
        self.init(
            pcmFormat: audioFile.processingFormat,
            frameCapacity: AVAudioFrameCount(audioFile.length)
        )!

        try audioFile.read(into: self)
    }
}
