import Foundation
import UIKit

extension CompositionViewController {
    private enum Constants {
        static let combinationSpacing: CGFloat = 16
        static let horizontalOffsets: CGFloat = 16
        static let verticalOffsets: CGFloat = 16

        static let combinationsNotFoundLabelTopOffset: CGFloat = 32
    }
}

final class CompositionViewController: UIViewController {
    
    private let viewModel: CompositionViewModelInput

    private let combinationsNotFoundLabel = UILabel()

    private lazy var combinationsView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = Constants.combinationSpacing
        flowLayout.sectionInset = .init(
            top: Constants.verticalOffsets,
            left: Constants.horizontalOffsets,
            bottom: Constants.verticalOffsets,
            right: Constants.horizontalOffsets
        )
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.alwaysBounceVertical = true
        collectionView.register(
            CombinationCollectionViewCell.self,
            forCellWithReuseIdentifier: CombinationCollectionViewCell.reuseIdentifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        return collectionView
    }()

    private lazy var infoButtonItem: UIBarButtonItem = .init(image: .init(systemName: "ellipsis.circle"), menu: infoMenu)
    private lazy var createCombinationButtonItem: UIBarButtonItem = .init(
        image: .init(systemName: "plus.square"),
        style: .plain,
        target: self,
        action: #selector(onCreateCombinationButtonTapped(_:))
    )

    private var infoMenu: UIMenu {
        let menuItems: [UIAction] = [
            .init(title: "Параметры", image: .init(systemName: "doc"), handler: { [weak self] _ in
                self?.viewModel.compositionParametersButtonTapped()
            }),
            .init(
                title: "Добавить в избранное",
                image: .init(systemName: "heart"),
                handler: { [weak self] _ in
                    self?.viewModel.favouriteButtonTapped()
                }
            ),
            .init(title: "Сделать форк", image: .init(systemName: "arrow.triangle.branch"), handler: { [weak self] _ in
                self?.viewModel.forkButtonTapped()
            })
        ]
        
        return .init(children: menuItems)
    }

    init(viewModel: CompositionViewModelInput) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        layout()
        configure()
        updateCombinations()
    }
    
    private func configure() {
        let bpmStepper = BPMStepper(value: viewModel.getInitialBPM(), minimumValue: 30, maximumValue: 240)
        bpmStepper.addTarget(self, action: #selector(onBPMStepperValueChanged), for: .valueChanged)
        navigationItem.titleView = bpmStepper
        navigationItem.titleView?.isUserInteractionEnabled = true
        
        navigationItem.rightBarButtonItems = [infoButtonItem, createCombinationButtonItem]
        navigationItem.leftBarButtonItem = .init(
            image: .init(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(onCloseButtonPressed(_:))
        )

        combinationsNotFoundLabel.text = "Комбинации отсутствуют"
        combinationsNotFoundLabel.role(.secondary)
        combinationsNotFoundLabel.textColor = .secondaryLabel
    }

    private func layout() {
        view.addSubview(combinationsView)
        view.addSubview(combinationsNotFoundLabel)
        combinationsView.translatesAutoresizingMaskIntoConstraints = false
        combinationsNotFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            combinationsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            combinationsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            combinationsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            combinationsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            combinationsNotFoundLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            combinationsNotFoundLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.combinationsNotFoundLabelTopOffset
            )
        ])
    }

    @objc
    private func onCreateCombinationButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.createCombinationButtonTapped()
    }

    @objc
    private func onCloseButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @objc
    private func onBPMStepperValueChanged(_ sender: BPMStepper) {
        viewModel.setBPM(sender.value)
    }
}

extension CompositionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let viewWidth = combinationsView.bounds.width
        let itemSize = (viewWidth - Constants.combinationSpacing - 2 * Constants.horizontalOffsets) / 2
        return .init(width: itemSize, height: itemSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.combinationTapped(atIndex: indexPath.row)
    }
}

extension CompositionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.getCombinationNames().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CombinationCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? CombinationCollectionViewCell
        
        cell?.setup(
            combinationName: viewModel.getCombinationNames()[indexPath.row],
            isPlaying: viewModel.getCombinationsIsPlaying()[indexPath.row],
            onPlayButtonTapped: { [weak self] in
                self?.viewModel.combinationPlayButtonTapped(atIndex: indexPath.row)
            }, onEffectsButtonTapped: { [weak self] in
                self?.viewModel.combinationEffectsButtonTapped(atIndex: indexPath.row)
            }
        )

        return cell ?? UICollectionViewCell()
    }
}

extension CompositionViewController: CompositionViewModelOutput { 
    func updateCombinations() {
        if viewModel.getCombinationNames().count == 0 {
            combinationsNotFoundLabel.isHidden = false
            combinationsView.isHidden = true
        } else {
            combinationsView.reloadData()
            combinationsNotFoundLabel.isHidden = true
            combinationsView.isHidden = false
        }
    }
}
