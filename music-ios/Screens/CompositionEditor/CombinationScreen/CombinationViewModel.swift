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

    private let combinationManager: CombinationManager
    private let effectsManager: EffectsManager

    private var melodyEditor: MelodyEditor?
    private var chooseMelody: ChooseMelody?

    init(combinationManager: CombinationManager, effectsManager: EffectsManager) {
        self.combinationManager = combinationManager
        self.effectsManager = effectsManager
    }

    private func showMelodyEditor(atIndex index: Int) {
        let internalMetronome = Metronome(bpm: combinationManager.getBPM())
        combinationManager.prepareMelodyForEditing(atIndex: index, withMetronome: internalMetronome)
        let melodyEditor = MelodyEditor(
            internalMetronome: internalMetronome,
            melodyManager: combinationManager.melodyManagers[index],
            effectsManager: combinationManager.melodyEffectsManagers[index],
            onClose: { [weak self] in
                self?.combinationManager.restoreMelodyFromEditing(atIndex: index)
            }
        )

        self.melodyEditor = melodyEditor
        DispatchQueue.main.async {
            self.view?.present(melodyEditor.getViewController(), animated: true)
        }
    }
}

extension CombinationViewModel: CombinationViewModelInput {
    func getInitialPlayButtonState() -> Bool {
        !combinationManager.getMuteState()
    }
    
    func getMelodies() -> [CombinationMelodyMiniature] {
        let melodyNames = combinationManager.getMelodyNames()
        let melodyMuteStates = combinationManager.getMelodyMuteStates()
        return (0 ..< melodyNames.count).map { .init(name: melodyNames[$0], isMuted: melodyMuteStates[$0]) }
    }
    
    func getSamples() -> [CombinationSampleMiniature] {
        []  // TODO.
    }

    func muteButtonTapped(atSampleIndex index: Int) {
        // TODO.
    }

    func muteButtonTapped(atMelodyIndex index: Int) {
        combinationManager.setMuteState(
            forMelodyAtIndex: index,
            isMuted: !combinationManager.getMelodyMuteStates()[index]
        )
        
        view?.updateMelody(
            atIndex: index,
            melodyMiniature: .init(
                name: combinationManager.getMelodyNames()[index],
                isMuted: combinationManager.getMelodyMuteStates()[index]
            )
        )
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
        combinationManager.setMuteState(isMuted: !combinationManager.getMuteState())
        view?.updatePlayButtonState(isPlaying: !combinationManager.getMuteState())
    }
    
    func effectsButtonTapped() {
        let effectsEditor = EffectEditor(effectsManager: effectsManager)
        let viewController = effectsEditor.getViewController()
        view?.present(viewController, animated: true)
    }

    func addMelodyButtonTapped() {
        var melodyWasUserCreated = false
        let chooseMelody = ChooseMelody(
            metronomeBPM: combinationManager.getBPM(),
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

                self?.combinationManager.setOverallVolume(1)
            }
        )

        self.chooseMelody = chooseMelody
        combinationManager.setOverallVolume(0.25)
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
