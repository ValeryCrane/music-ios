import Foundation
import AVFoundation

final class CombinationManager {
    var outputNode: AVAudioNode {
        mainNode
    }

    let metronome: Metronome
    let combination: MutableCombination
    private(set) var melodyManagers: [MelodyManager]
    private(set) var melodyEffectsManagers: [EffectsManager]

    private let mainNode: AVAudioMixerNode
    private let audioEngineManager = AudioEngineManager()

    init(combination: MutableCombination, metronome: Metronome) async throws {
        self.combination = combination
        self.metronome = metronome

        let mainNode = AVAudioMixerNode()
        let melodyEffectsManagers = combination.melodies.map { EffectsManager(effects: $0.effects) }
        let melodyManagers = try await withThrowingTaskGroup(of: (Int, MelodyManager).self) { group in
            var keyMap = [Int: MelodyManager]()

            combination.melodies.enumerated().forEach { (index, melody) in
                group.addTask {
                    return (index, try await MelodyManager(melody: melody, metronome: metronome))
                }
            }

            for try await melodyManagerInfo in group {
                keyMap[melodyManagerInfo.0] = melodyManagerInfo.1
            }

            return (0 ..< combination.melodies.count).compactMap { keyMap[$0] }
        }

        audioEngineManager.attachNode(mainNode)
        for i in 0 ..< combination.melodies.count {
            audioEngineManager.connect(melodyManagers[i].outputNode, to: melodyEffectsManagers[i].inputNode)
            audioEngineManager.connect(melodyEffectsManagers[i].outputNode, to: mainNode)
        }

        self.mainNode = mainNode
        self.melodyEffectsManagers = melodyEffectsManagers
        self.melodyManagers = melodyManagers
    }

    func addMelody(_ melody: MutableMelody) async throws {
        combination.melodies.append(melody)
        let effectsManager = EffectsManager(effects: melody.effects)
        let melodyManager = try await MelodyManager(melody: melody, metronome: metronome)
        audioEngineManager.connect(melodyManager.outputNode, to: effectsManager.inputNode)
        audioEngineManager.connect(effectsManager.outputNode, to: mainNode)
        melodyManager.startIfMetronomeIsPlaying()
        melodyEffectsManagers.append(effectsManager)
        melodyManagers.append(melodyManager)
    }
}
