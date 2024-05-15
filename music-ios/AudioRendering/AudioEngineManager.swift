import Foundation
import AVFoundation

final class AudioEngineManager {
    static let engine = AVAudioEngine()
    static let effectsManager = EffectsManager(effects: .init(effects: .init()))

    static var inputNodeFormat: AVAudioFormat {
        engine.inputNode.outputFormat(forBus: 0)
    }

    static var outputNodeFormat: AVAudioFormat {
        engine.mainMixerNode.outputFormat(forBus: 0)
    }

    private static let inputMixer = AVAudioMixerNode()

    func attachNode(_ node: AVAudioNode) {
        Self.engine.attach(node)
    }

    func detachNode(_ node: AVAudioNode) {
        Self.engine.detach(node)
    }

    func addNodeToMainMixer(_ node: AVAudioNode, format: AVAudioFormat? = nil) {
        Self.engine.connect(node, to: Self.engine.mainMixerNode, format: format)
        do {
            if !Self.engine.isRunning {
                // Подгружаем входною вершину перед запуском, так как во время запуска этого сделать не выйдет.
                connectInputNodeToMainMixer()
                try Self.engine.start()
            }
        } catch {
            print("AVAUDIOENGINE STARTUP FAILED")
            print(error.localizedDescription)
        }
    }

    func connect(_ node: AVAudioNode, to: AVAudioNode, format: AVAudioFormat? = nil) {
        Self.engine.connect(node, to: to, format: format)
    }

    func disconnect(_ node: AVAudioNode) {
        Self.engine.disconnectNodeOutput(node)
    }

    func recordSoundFromInput(bufferSize: AVAudioFrameCount, handler: @escaping (AVAudioPCMBuffer, AVAudioTime) -> Void) {
        Self.engine.inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: Self.inputNodeFormat, block: handler)
    }

    func recordSoundFromOutput(bufferSize: AVAudioFrameCount, handler: @escaping (AVAudioPCMBuffer, AVAudioTime) -> Void) {
        Self.engine.mainMixerNode.installTap(onBus: 0, bufferSize: bufferSize, format: nil, block: handler)
    }

    func stopInputSoundRecording() {
        Self.engine.inputNode.removeTap(onBus: 0)
    }

    func stopOutputSoundRecording() {
        Self.engine.mainMixerNode.removeTap(onBus: 0)
    }

    private func connectInputNodeToMainMixer() {
        attachNode(Self.inputMixer)
        Self.inputMixer.outputVolume = 0
        Self.engine.connect(Self.engine.inputNode, to: Self.effectsManager.inputNode, format: Self.inputNodeFormat)
        Self.engine.connect(Self.effectsManager.inputNode, to: Self.inputMixer, format: Self.inputNodeFormat)
        Self.engine.connect(Self.inputMixer, to: Self.engine.mainMixerNode, format: Self.inputNodeFormat)
    }
}
