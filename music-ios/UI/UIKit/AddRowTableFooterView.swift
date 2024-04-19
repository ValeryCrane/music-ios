import Foundation
import UIKit

extension AddRowTableFooterView {
    private enum Constants {
        static let verticalOffsets: CGFloat = 8
        static let horizontalOffsets: CGFloat = 8
        static let imageSpacing: CGFloat = 4
    }
}

final class AddRowTableFooterView: UIControl {
    private let buttonView = UIView()
    private let buttonLabel = UILabel()
    private let buttonImage = UIImageView(image: .init(systemName: "plus"))
    
    init(title: String) {
        super.init(frame: .zero)
        
        buttonLabel.text = title
        configure()
        layout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        buttonView.layer.cornerRadius = .defaultCornerRadius
        buttonView.backgroundColor = .imp.lightGray
        buttonLabel.role(.secondary)
        buttonLabel.textColor = .darkGray
        buttonImage.tintColor = .darkGray
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onButtonPressed(_:)))
        buttonView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func layout() {
        let stackView = UIStackView(arrangedSubviews: [buttonImage, buttonLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Constants.imageSpacing
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonView)
        buttonView.addSubview(stackView)
        NSLayoutConstraint.activate([
            buttonView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: Constants.verticalOffsets),
            stackView.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: Constants.horizontalOffsets),
            stackView.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -Constants.horizontalOffsets),
            stackView.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: -Constants.verticalOffsets)
        ])
    }
    
    @objc
    private func onButtonPressed(_ sener: UITapGestureRecognizer) {
        sendActions(for: .touchUpInside)
    }
}
