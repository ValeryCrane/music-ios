import Foundation
import UIKit

protocol CompositionViewModelInput: AnyObject { 
    func getCombinationNames() -> [String]
    func getCombinationsIsPlaying() -> [Bool]
    func getInitialBPM() -> Int

    func setBPM(_ bpm: Int)

    func combinationTapped(atIndex index: Int)
    func combinationPlayButtonTapped(atIndex index: Int)
    func combinationEffectsButtonTapped(atIndex index: Int)
    func compositionParametersButtonTapped()
    func favouriteButtonTapped()
    func forkButtonTapped()
    func createCombinationButtonTapped()
}

protocol CompositionViewModelOutput: UIViewController { 
    func updateCombinations()
}

final class CompositionViewModel {
    weak var view: CompositionViewModelOutput?
    weak var toolbarManager: CompositionNavigationControllerInput?

    private let compositionBlueprintEdit = Requests.CompositionBlueprintEdit()

    private let compositionManager: CompositionRenderManager
    private let compositionParametersScreen: CompositionParametersScreen

    private var createCombinationAlertAction: UIAlertAction?
    private var combinationEditor: CombinationEditor?

    init(compositionManager: CompositionRenderManager, compositionParametersScreen: CompositionParametersScreen) {
        self.compositionManager = compositionManager
        self.compositionParametersScreen = compositionParametersScreen
        compositionManager.delegate = self
    }

    private func showCreateCombinationAlert() {
        let alertViewController = UIAlertController(title: "Создание комбинации", message: "Введите название комбинации", preferredStyle: .alert)
        alertViewController.addTextField { [weak self] textField in
            textField.placeholder = "Припев"
            if let self = self {
                textField.addTarget(self, action: #selector(onCreateCombinationAlertTextFieldEdited(_:)), for: .editingChanged)
            }
        }

        let createCombinationAlertAction = UIAlertAction(
            title: "Создать",
            style: .default
        ) { [weak self] _ in
            if let text = alertViewController.textFields?.first?.text, !text.isEmpty {
                self?.createCombination(withName: text)
            }
        }

        alertViewController.addAction(.init(title: "Отмена", style: .cancel))
        alertViewController.addAction(createCombinationAlertAction)
        createCombinationAlertAction.isEnabled = false
        self.createCombinationAlertAction = createCombinationAlertAction

        view?.present(alertViewController, animated: true)
    }

    private func showSaveCompositionAlert() {
        let alertViewController = UIAlertController(title: "Сохранить изменения в композиции?", message: nil, preferredStyle: .alert)
        alertViewController.addAction(.init(title: "Отмена", style: .cancel))
        alertViewController.addAction(.init(title: "Сохранить", style: .default, handler: { [weak self] _ in
            self?.saveComposition()
        }))

        view?.present(alertViewController, animated: true)
    }

    private func createCombination(withName name: String) {
        Task {
            try await compositionManager.addCombination(.init(.empty(withName: name)))
            await MainActor.run {
                view?.updateCombinations()
            }
        }
    }

    @objc
    private func onCreateCombinationAlertTextFieldEdited(_ sender: UITextField) {
        if let text = sender.text, !text.isEmpty {
            createCombinationAlertAction?.isEnabled = true
        } else {
            createCombinationAlertAction?.isEnabled = false
        }
    }

    private func saveComposition() {
        Task {
            await MainActor.run {
                view?.startLoader()
            }

            try await compositionBlueprintEdit.run(
                with: compositionManager.getComposition().compositionBlueprintEditParameters()
            )

            await MainActor.run {
                view?.stopLoader()
                toolbarManager?.hideSaveButton()
            }
        }
    }
}

extension CompositionViewModel: CompositionViewModelInput {
    func getCombinationNames() -> [String] {
        compositionManager.getCombinationNames()
    }
    
    func getCombinationsIsPlaying() -> [Bool] {
        compositionManager.getCombinationMuteStates().map(!)
    }

    func getInitialBPM() -> Int {
        Int(compositionManager.getBPM())
    }

    func setBPM(_ bpm: Int) {
        compositionManager.setBPM(Double(bpm))
    }

    func combinationTapped(atIndex index: Int) {
        let combinationManager = compositionManager.combinationManagers[index]
        let effectsManager = compositionManager.effectsManagers[index]
        let combinationEditor = CombinationEditor(combinationManager: combinationManager, effectsManager: effectsManager)
        self.combinationEditor = combinationEditor
        view?.navigationController?.pushViewController(combinationEditor.getViewController(), animated: true)
    }

    func combinationPlayButtonTapped(atIndex index: Int) {
        if compositionManager.getCombinationMuteStates()[index] {
            compositionManager.playCombination(atIndex: index)
        } else {
            compositionManager.stopPlaying()
        }

        view?.updateCombinations()
    }

    func combinationEffectsButtonTapped(atIndex index: Int) {
        let effectsEditor = EffectEditor(effectsManager: compositionManager.effectsManagers[index])
        let viewController = effectsEditor.getViewController()
        view?.present(viewController, animated: true)
    }

    func compositionParametersButtonTapped() {
        let viewController = compositionParametersScreen.getViewController()
        view?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func favouriteButtonTapped() {
        // TODO.
    }
    
    func forkButtonTapped() {
        // TODO.
    }
    
    func createCombinationButtonTapped() {
        showCreateCombinationAlert()
    }
}

extension CompositionViewModel: CompositionRenderManagerDelegate {
    func compositionRenderManagerDidChangeComposition(_ compositionRenderManager: CompositionRenderManager) {
        DispatchQueue.main.async {
            self.toolbarManager?.showSaveButton()
        }
    }

    func compositionRenderManagerDidUpdateCombinationMuteStates(_ compositionRenderManager: CompositionRenderManager) {
        view?.updateCombinations()
    }
}

extension CompositionViewModel: CompositionNavigationControllerOutput {
    func saveButtonTapped() {
        showSaveCompositionAlert()
    }
}
