import Foundation
import UIKit

extension LoadingViewController {
    private enum Constants {
        static let loadingViewSize: CGFloat = 48
    }
}

class LoadingViewController: UIViewController {
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        activityIndicator.style = .medium
        activityIndicator.tintColor = .imp.primary
        activityIndicator.startAnimating()
        
        layout()
    }
    
    private func layout() {
        let loadingView = UIView()
        loadingView.backgroundColor = .imp.lightGray
        loadingView.layer.cornerRadius = .defaultCornerRadius
        
        view.addSubview(loadingView)
        loadingView.addSubview(activityIndicator)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.widthAnchor.constraint(equalToConstant: Constants.loadingViewSize),
            loadingView.heightAnchor.constraint(equalToConstant: Constants.loadingViewSize),
            
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        ])
    }
}
