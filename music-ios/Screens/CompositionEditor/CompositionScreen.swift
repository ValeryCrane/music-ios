import Foundation
import UIKit

final class CompositionScreen {

    private let compositionEditor: CompositionEditor

    init(composition: Composition) async throws {
        let metronome = Metronome(bpm: Double(composition.bpm))
        let compositionManager = try await CompositionRenderManager(composition: .init(composition))
        compositionEditor = CompositionEditor(compositionManager: compositionManager)
    }

    func getViewController()  -> UIViewController {
        compositionEditor.getViewController()
    }
}
