import Foundation
import UIKit

final class CompositionScreen {

    private let compositionEditor: CompositionEditor

    init(composition: Composition) async throws {
        let metronome = Metronome(bpm: Double(composition.bpm))
        let mutableComposition = MutableComposition(composition)
        let compositionManager = try await CompositionRenderManager(composition: mutableComposition)
        let compositionParametersScreen = CompositionParametersScreen(
            composition: mutableComposition,
            onCompositionDeleted: {}
        )
        compositionEditor = CompositionEditor(
            compositionManager: compositionManager,
            compositionParametersScreen: compositionParametersScreen
        )
    }

    func getViewController() -> UIViewController {
        compositionEditor.getViewController()
    }
}
