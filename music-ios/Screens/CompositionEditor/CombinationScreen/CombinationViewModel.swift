import Foundation
import UIKit

protocol CombinationViewModelInput: AnyObject {
    func getInitialPlayButtonState() -> Bool
    func getMelodies() -> [CombinationMelodyMiniature]
    func getSamples() -> [CombinationSampleMiniature]

    func muteButtonTapped(atSampleIndex index: Int)
    func muteButtonTapped(atMelodyIndex index: Int)
    func effectsButtonTapped(atSampleIndex index: Int)
    func effectsButtonTapped(atMelodyIndex index: Int)
    func editButtonTapped(atMelodyIndex index: Int)
    func playButtonTapped()
    func effectsButtonTapped()
    func addMelodyButtonTapped()
    func addSampleButtonTapped()
}

protocol CombinationViewModelOutput: UIViewController {
    func updatePlayButtonState(isPlaying: Bool)
    func updateSample(atIndex index: Int, sampleMiniature: CombinationSampleMiniature)
    func updateMelody(atIndex index: Int, melodyMiniature: CombinationMelodyMiniature)
    func updateMelodiesAndSamples()
}

final class CombinationViewModel {
    
    weak var view: CombinationViewModelOutput?
    
    private let metronome: Metronome
    private let combinationManager: CombinationManager
    private let effectsManager: EffectsManager

    private var melodyEditor: MelodyEditor?
    private var chooseMelody: ChooseMelody?

    init(combinationManager: CombinationManager, effectsManager: EffectsManager) {
        self.metronome = combinationManager.metronome
        self.combinationManager = combinationManager
        self.effectsManager = effectsManager
        metronome.addListener(self)
    }

    private func showMelodyEditor(atIndex index: Int) {
        let melodyEditor = MelodyEditor(
            melodyManager: combinationManager.melodyManagers[index],
            effectsManager: combinationManager.melodyEffectsManagers[index]
        )

        self.melodyEditor = melodyEditor
        DispatchQueue.main.async {
            self.view?.present(melodyEditor.getViewController(), animated: true)
        }
    }
}

extension CombinationViewModel: CombinationViewModelInput {
    func getInitialPlayButtonState() -> Bool {
        metronome.isPlaying
    }
    
    func getMelodies() -> [CombinationMelodyMiniature] {
        combinationManager.combination.melodies.map { melody in
            .init(name: melody.name, isMuted: melody.isMuted)
        }
    }
    
    func getSamples() -> [CombinationSampleMiniature] {
        []  // TODO.
    }

    func muteButtonTapped(atSampleIndex index: Int) {
        // TODO.
    }

    func muteButtonTapped(atMelodyIndex index: Int) {
        let melodyManager = combinationManager.melodyManagers[index]
        melodyManager.setMuteState(isMuted: !melodyManager.isMuted)
        let melody = combinationManager.combination.melodies[index]
        view?.updateMelody(atIndex: index, melodyMiniature: .init(name: melody.name, isMuted: melody.isMuted))
    }

    func effectsButtonTapped(atSampleIndex index: Int) {
        // TODO.
    }
    
    func effectsButtonTapped(atMelodyIndex index: Int) {
        let effectsEditor = EffectEditor(effectsManager: combinationManager.melodyEffectsManagers[index])
        let viewController = effectsEditor.getViewController()
        view?.present(viewController, animated: true)
    }
    
    func editButtonTapped(atMelodyIndex index: Int) {
        showMelodyEditor(atIndex: index)
    }
    
    func playButtonTapped() {
        if metronome.isPlaying {
            metronome.reset()
        } else {
            metronome.play()
        }
    }
    
    func effectsButtonTapped() {
        let effectsEditor = EffectEditor(effectsManager: effectsManager)
        let viewController = effectsEditor.getViewController()
        view?.present(viewController, animated: true)
    }

    func addMelodyButtonTapped() {
        var melodyWasUserCreated = false
        let chooseMelody = ChooseMelody(
            metronomeBPM: metronome.bpm,
            melodyCreationHandler: { [weak self] chooseMelodyResult in
                do {
                    melodyWasUserCreated = chooseMelodyResult.userCreated
                    try await self?.addMelody(chooseMelodyResult.melody)
                } catch {
                    print(error.localizedDescription)
                }
            },
            closeHandler: { [weak self] in
                if melodyWasUserCreated, let melodyCount = self?.combinationManager.melodyManagers.count {
                    self?.showMelodyEditor(atIndex: melodyCount - 1)
                }
            }
        )

        self.chooseMelody = chooseMelody
        view?.present(chooseMelody.getViewController(), animated: true)
    }

    private func addMelody(_ melody: MutableMelody) async throws  {
        try await combinationManager.addMelody(melody)
        await MainActor.run {
            view?.updateMelodiesAndSamples()
        }
    }

    func addSampleButtonTapped() {
        let viewModel = ChooseSampleViewModel()
        let viewController = ChooseSampleViewController(viewModel: viewModel)
        viewModel.view = viewController
        view?.present(UINavigationController(rootViewController: viewController), animated: true)
    }
}

extension CombinationViewModel: MetronomeListener {
    func metronome(_ metronome: Metronome, didStartPlayingAtBeat beat: Double) {
        view?.updatePlayButtonState(isPlaying: true)
    }
    
    func metronome(_ metronome: Metronome, didStopPlayingAtBeat beat: Double) {
        view?.updatePlayButtonState(isPlaying: false)
    }
    
    func metronome(_ metronome: Metronome, didUpdateBPM bpm: Double) {
        // TODO.
    }
}
