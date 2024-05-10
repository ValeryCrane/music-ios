import Foundation
import UIKit

extension BottomSheetPresentationController {
    private enum Constants {
        static let dimmViewOpacity: Double = 0.3
        static let bottomSheetCornerRadius: CGFloat = 16
    }
}

final class BottomSheetPresentationController: UIPresentationController {

    private lazy var dimmView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(white: 0, alpha: Constants.dimmViewOpacity)
        view.alpha = 0

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onDimmViewTapped(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()

    override var frameOfPresentedViewInContainerView: CGRect {
        if let bounds = containerView?.bounds {
            let prefferedHeight = presentedViewController.preferredContentSize.height
            return .init(x: 0, y: bounds.maxY - prefferedHeight, width: bounds.width, height: prefferedHeight)
        }

        return .zero
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        if let presentedView = presentedView {
            containerView?.addSubview(dimmView)
            containerView?.addSubview(presentedView)
            presentedView.layer.cornerRadius = Constants.bottomSheetCornerRadius
            performAlongsideTransitionIfPossible { [weak self] in
                self?.dimmView.alpha = 1
            }
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)

        if (!completed) {
            dimmView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        performAlongsideTransitionIfPossible { [weak self] in
            self?.dimmView.alpha = 0
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)

        if completed {
            dimmView.removeFromSuperview()
        }
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()

        presentedView?.frame = frameOfPresentedViewInContainerView
        dimmView.frame = containerView?.frame ?? .zero
    }

    private func performAlongsideTransitionIfPossible(_ block: @escaping () -> Void) {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate { _ in
                block()
            }
        } else {
            block()
        }
    }

    @objc
    private func onDimmViewTapped(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true)
    }
}
