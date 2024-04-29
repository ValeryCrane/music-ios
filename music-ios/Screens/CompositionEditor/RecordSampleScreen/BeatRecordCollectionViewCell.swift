import Foundation
import UIKit

final class BeatRecordCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "BeatRecordCollectionViewCell"
    
    private let progressView = UIView()
    
    private var animator: UIViewPropertyAnimator?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(progressView)
        progressView.backgroundColor = .imp.complementary
        backgroundColor = .imp.lightGray
        clipsToBounds = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = layer.frame.height / 2
    }

    func start(beatDuration: TimeInterval, delay: TimeInterval) {
        progressView.frame = .init(origin: bounds.origin, size: .init(width: 0, height: bounds.height))
        animator = UIViewPropertyAnimator(duration: beatDuration, curve: .linear) {
            self.progressView.frame = self.bounds
        }
        animator?.startAnimation(afterDelay: delay)
    }
    
    func pause() {
        animator?.pauseAnimation()
    }
    
    func `continue`() {
        animator?.startAnimation()
    }
    
    func stop() {
        animator?.stopAnimation(false)
    }
    
    func reset() {
        animator?.stopAnimation(true)
        progressView.frame = .init(origin: bounds.origin, size: .init(width: 0, height: bounds.height))
    }
}
