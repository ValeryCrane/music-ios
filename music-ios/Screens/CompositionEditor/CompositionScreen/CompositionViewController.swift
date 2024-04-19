import Foundation
import UIKit

extension CompositionViewController {
    private enum Constants {
        static let combinationSpacing: CGFloat = 16
        static let horizontalOffsets: CGFloat = 16
        static let verticalOffsets: CGFloat = 16
    }
}

final class CompositionViewController: UIViewController {
    
    private let viewModel: CompositionViewModelInput
    
    private var isFavourite: Bool
    private var combinations: [MutableCombination]
    
    private lazy var combinationsView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = Constants.combinationSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.alwaysBounceVertical = true
        collectionView.register(
            CombinationCollectionViewCell.self,
            forCellWithReuseIdentifier: CombinationCollectionViewCell.reuseIdentifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private var infoMenu: UIMenu {
        let menuItems: [UIAction] = [
            .init(title: "Параметры", image: .init(systemName: "doc"), handler: { [weak self] _ in
                self?.viewModel.onCompositionsParametersButtonPressed()
            }),
            .init(
                title: isFavourite ? "Убрать из избранного" : "Добавить в избранное",
                image: .init(systemName: "heart"),
                handler: { [weak self] _ in
                    self?.isFavourite.toggle()
                    self?.viewModel.onFavouriteButtonPressed()
                }
            ),
            .init(title: "Сделать форк", image: .init(systemName: "arrow.triangle.branch"), handler: { [weak self] _ in
                // TODO
            })
        ]
        
        return .init(children: menuItems)
    }
    
    init(viewModel: CompositionViewModelInput) {
        self.viewModel = viewModel
        self.combinations = viewModel.getCombinations()
        self.isFavourite = viewModel.getIsFavourite()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(combinationsView)
        combinationsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            combinationsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.verticalOffsets),
            combinationsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalOffsets),
            combinationsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalOffsets),
            combinationsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalOffsets)
        ])
        
        configureNavigationItem()
        configureRecordToolbar()
    }
    
    private func configureNavigationItem() {
        navigationItem.titleView = BPMStepper(value: 120, minimumValue: 30, maximumValue: 240)
        navigationItem.titleView?.isUserInteractionEnabled = true
        
        navigationItem.rightBarButtonItem = .init(image: .init(systemName: "ellipsis.circle"), menu: infoMenu)
        navigationItem.leftBarButtonItem = .init(
            image: .init(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(onCloseButtonPressed(_:))
        )
    }
    
    private func configureRecordToolbar() {
        guard let navigationController = navigationController else { return }
        
        let recordToolbar = RecordToolbarView()
        recordToolbar.translatesAutoresizingMaskIntoConstraints = false
        navigationController.view.addSubview(recordToolbar)
        navigationController.view.bringSubviewToFront(recordToolbar)
        
        NSLayoutConstraint.activate([
            recordToolbar.leadingAnchor.constraint(equalTo: navigationController.view.leadingAnchor),
            recordToolbar.trailingAnchor.constraint(equalTo: navigationController.view.trailingAnchor),
            recordToolbar.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor)
        ])
        
    }
    
    @objc
    private func onCloseButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension CompositionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let viewWidth = combinationsView.bounds.width
        let itemSize = (viewWidth - Constants.combinationSpacing) / 2
        return .init(width: itemSize, height: itemSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.onOpenCombination(combinations[indexPath.row])
    }
}

extension CompositionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        combinations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CombinationCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? CombinationCollectionViewCell
        
        cell?.setup(combination: combinations[indexPath.row])
        return cell ?? UICollectionViewCell()
    }
}

extension CompositionViewController: CompositionViewModelOutput { }
