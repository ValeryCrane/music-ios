import Foundation
import UIKit
import SwiftUI

final class CompositionsViewController: UIHostingController<CompositionsView> {
    
    private let viewModel: CompositionsViewModel
    
    init(compositionManager: CompositionManager) {
        let viewModel = CompositionsViewModel(compositionManager: compositionManager)
        let rootView = CompositionsView(viewModel: viewModel)
        self.viewModel = viewModel
        
        super.init(rootView: rootView)

        viewModel.viewController = self
        configureNavigationItem()
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationItem() {
        title = "Композиции"
        navigationItem.rightBarButtonItem = .init(
            image: .init(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(createCompositionButtonPressed(_:))
        )
    }
    
    @objc
    private func createCompositionButtonPressed(_ sender: UIBarButtonItem) {
        showCreateCompositionAlert()
    }
    
    private func showCreateCompositionAlert() {
        let alert = UIAlertController(title: "Создание композиции", message: "Введите название композиции", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Нужен только бит"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert, weak self] (_) in
            guard let alert = alert, let self = self else { return }
            let textField = alert.textFields![0]
            self.viewModel.onCreateComposition(name: textField.text ?? "")
        }))
        
        present(alert, animated: true)
    }
}
