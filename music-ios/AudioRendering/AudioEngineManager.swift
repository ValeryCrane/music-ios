import Foundation
import AVFoundation

final class AudioEngineManager {
    static let engine = AVAudioEngine()

    func attachNode(_ node: AVAudioNode) {
        Self.engine.attach(node)
    }

    func detachNode(_ node: AVAudioNode) {
        Self.engine.detach(node)
    }

    func addNodeToMainMixer(_ node: AVAudioNode, format: AVAudioFormat = engine.mainMixerNode.inputFormat(forBus: 0)) {
        Self.engine.connect(node, to: Self.engine.mainMixerNode, format: format)
        do {
            try Self.engine.start()
        } catch {
            print("AVAUDIOENGINE STARTUP FAILED")
            print(error.localizedDescription)
        }
    }

    func connect(_ node: AVAudioNode, to: AVAudioNode, format: AVAudioFormat? = nil) {
        Self.engine.connect(node, to: to, format: format)
    }
}
