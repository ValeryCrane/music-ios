import Foundation
import AVFoundation

protocol KeyboardPreviewManagerDelegate: AnyObject {
    func deyboardPreviewManagerDidCompleteLoading(keyboardWithId keyboardId: Int)
}

extension KeyboardPreviewManager {
    private enum Constants {
        static let noteStartTimes: [TimeInterval] = [0.1, 0.5, 0.9]
        static let notes: [Int] = [0, 2, 4]
    }
}

final class KeyboardPreviewManager {
    weak var delegate: KeyboardPreviewManagerDelegate?

    var outputNode: AVAudioNode {
        mainNode
    }

    private let keyboardCachingManager = KeyboardCachingManager()
    private let audioEngineManager = AudioEngineManager()
    private let mainNode = AVAudioMixerNode()
    private let nodes: [AVAudioPlayerNode]

    init() {
        var nodes = [AVAudioPlayerNode]()
        audioEngineManager.attachNode(mainNode)
        for _ in 0 ..< Constants.notes.count {
            let node = AVAudioPlayerNode()
            audioEngineManager.attachNode(node)
            audioEngineManager.connect(node, to: mainNode)
            nodes.append(node)
        }

        self.nodes = nodes
    }

    deinit {
        nodes.forEach { audioEngineManager.detachNode($0) }
        audioEngineManager.detachNode(mainNode)
    }

    func preview(keyboardId: Int) async throws {
        nodes.forEach { $0.stop() }

        let keyboard = try await keyboardCachingManager.loadKeyboard(id: keyboardId)
        let currentTime = mach_absolute_time()
        for i in 0 ..< Constants.notes.count {
            try scheduleNote(index: i, keys: keyboard.keys, currentTime: currentTime)
        }
    }

    private func scheduleNote(index: Int, keys: [URL], currentTime: UInt64) throws {
        let buffer = try AVAudioPCMBuffer(from: keys[Constants.notes[index]])
        let scheduleTime = AVAudioTime(
            hostTime: currentTime + AVAudioTime.hostTime(forSeconds: Constants.noteStartTimes[index])
        )

        nodes[index].scheduleBuffer(buffer, at: scheduleTime)
        nodes[index].play()
    }
}
