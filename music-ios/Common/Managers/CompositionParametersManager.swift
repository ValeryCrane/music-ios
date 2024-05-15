import Foundation

final class CompositionParametersManager {

    private let compositionVisibilityEdit = Requests.CompositionVisibilityEdit()
    private let compositionAddEditor = Requests.CompositionAddEditor()
    private let compositionRemoveEditor = Requests.CompositionRemoveEditor()
    private let compositionDelete = Requests.CompositionDelete()
    private let compositionHistory = Requests.CompositionHistoryGet()

    func updateVisibility(compositionId: Int, visibility: CompositionVisibility) async throws {
        try await compositionVisibilityEdit.run(with: .init(id: compositionId, visibility: visibility))
    }

    func addEditor(compositionId: Int, editorId: Int) async throws {
        try await compositionAddEditor.run(with: .init(id: compositionId, editorId: editorId))
    }

    func removeEditor(compositionId: Int, editorId: Int) async throws {
        try await compositionRemoveEditor.run(with: .init(id: compositionId, editorId: editorId))
    }

    func deleteComposition(compositionId: Int) async throws {
        try await compositionDelete.run(with: .init(id: compositionId))
    }

    func getCompositionHistory(compositionId: Int) async throws -> [CompositionHistoryEvent] {
        let compositionHistoryResponse = try await compositionHistory.run(with: .init(id: compositionId))
        return compositionHistoryResponse.blueprints.map { .init(from: $0) }
    }
}
