import Foundation
import UIKit

protocol CompositionParametersViewModelInput {
    func getName() -> String
    func getVisibility() -> CompositionVisibility
    func getCreator() -> User
    func getEditors() -> [User]
    func changeNameButtonTapped()
    func changeVisibilityButtonTapped()
    func addEditorButtonTapped()
    func editorLongTapped(atIndex index: Int)
    func historyButtonTapped()
    func deleteButtonTapped()
}

protocol CompositionParametersViewModelOutput: UIViewController {
    func updateName()
    func updateVisibility()
    func updateEditors()
}

// TODO: Выделить работы непостредственно с composition в CompositionParametersManager.
final class CompositionParametersViewModel {
    weak var view: CompositionParametersViewModelOutput?

    private let composition: MutableComposition
    private let compositionParametersManager: CompositionParametersManager

    private let onCompositionDeleted: () -> Void

    init(
        composition: MutableComposition,
        compositionParametersManager: CompositionParametersManager,
        onCompositionDeleted: @escaping () -> Void
    ) {
        self.composition = composition
        self.compositionParametersManager = compositionParametersManager
        self.onCompositionDeleted = onCompositionDeleted
    }

    private func showChangeNameAlert() {
        // TODO.
    }

    private func showChangeVisibilyAlert() {
        let alertViewController = UIAlertController(
            title: composition.visibility.changeVisibilityAlertTitle,
            message: composition.visibility.changeVisibilityAlertMessage,
            preferredStyle: .alert
        )
        alertViewController.addAction(.init(title: "Отмена", style: .cancel))
        alertViewController.addAction(.init(
            title: composition.visibility.changeVisibilityButtonTitle,
            style: .destructive,
            handler: { [weak self] _ in
                self?.changeVisibility()
            }
        ))

        view?.present(alertViewController, animated: true)
    }

    private func showRemoveEditorAlert(editorIndex: Int) {
        let editor = composition.editors[editorIndex]
        let alertViewController = UIAlertController(
            title: "Отозвать права редактирования у пользователя \(editor.username)?",
            message: nil,
            preferredStyle: .actionSheet
        )

        alertViewController.addAction(.init(title: "Отмена", style: .cancel))
        alertViewController.addAction(.init(title: "Отозвать", style: .destructive, handler: { [weak self] _ in
            self?.removeEditor(atIndex: editorIndex)
        }))

        view?.present(alertViewController, animated: true)
    }

    private func showDeleteCompositionAlert() {
        let alertViewController = UIAlertController(
            title: "Удалить композицию?",
            message: "Отменить это действие невозможно",
            preferredStyle: .actionSheet
        )

        alertViewController.addAction(.init(title: "Отмена", style: .cancel))
        alertViewController.addAction(.init(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            self?.deleteComposition()
        }))

        view?.present(alertViewController, animated: true)
    }

    private func changeName(name: String) {
        // TODO.
    }

    private func changeVisibility() {
        view?.startLoader()
        Task {
            try await compositionParametersManager.updateVisibility(
                compositionId: composition.id,
                visibility: composition.visibility.other
            )

            composition.visibility = composition.visibility.other

            await MainActor.run {
                view?.stopLoader()
                view?.updateVisibility()
            }
        }
    }

    private func removeEditor(atIndex index: Int) {
        view?.startLoader()
        Task {
            try await compositionParametersManager.removeEditor(
                compositionId: composition.id,
                editorId: composition.editors[index].id
            )

            composition.editors.remove(at: index)

            await MainActor.run {
                view?.stopLoader()
                view?.updateEditors()
            }
        }
    }

    private func deleteComposition() {
        view?.startLoader()
        Task {
            try await self.compositionParametersManager.deleteComposition(compositionId: composition.id)
            await MainActor.run {
                view?.stopLoader()
                onCompositionDeleted()
            }
        }
    }

    private func addEditor(_ editor: User) async {
        do {
            try await self.compositionParametersManager.addEditor(
                compositionId: self.composition.id,
                editorId: editor.id
            )

            self.composition.editors.append(editor)

            await MainActor.run {
                self.view?.updateEditors()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension CompositionParametersViewModel: CompositionParametersViewModelInput {
    func getName() -> String {
        composition.name
    }
    
    func getVisibility() -> CompositionVisibility {
        composition.visibility
    }
    
    func getCreator() -> User {
        composition.creator
    }
    
    func getEditors() -> [User] {
        composition.editors
    }
    
    func changeNameButtonTapped() {
        showChangeNameAlert()
    }
    
    func changeVisibilityButtonTapped() {
        showChangeVisibilyAlert()
    }

    func addEditorButtonTapped() {
        let viewController = UserSearchScreen(
            ignoredUserIds: Set(composition.editors.map(\.id) + [composition.creator.id]),
            chooseUserHandler: { [weak self] editor in
                await self?.addEditor(editor)
            }
        ).getViewController()
        
        view?.present(viewController, animated: true)
    }

    func editorLongTapped(atIndex index: Int) {
        showRemoveEditorAlert(editorIndex: index)
    }

    func historyButtonTapped() {
        // TODO.
    }

    func deleteButtonTapped() {
        showDeleteCompositionAlert()
    }
}

fileprivate extension CompositionVisibility {
    var changeVisibilityAlertTitle: String {
        switch self {
        case .private:
            "Опубликовать композицию?"
        case .public:
            "Скрыть композицию?"
        }
    }

    var changeVisibilityAlertMessage: String {
        switch self {
        case .private:
            "Редактирование по прежнему останется доступно лишь создателю и редакторам, но композицию увидят все"
        case .public:
            "Редактирование останется доступно создателю и редакторам, но композиция станет недоступной для остальных пользователей"
        }
    }

    var changeVisibilityButtonTitle: String {
        switch self {
        case .private:
            "Опубликовать"
        case .public:
            "Скрыть"
        }
    }
}
