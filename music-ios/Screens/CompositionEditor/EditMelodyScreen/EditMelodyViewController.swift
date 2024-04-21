import Foundation
import UIKit

extension EditMelodyViewController {
    private enum Constants {
        static let keyWidth: CGFloat = 128
        static let stepperVerticalOffsets: CGFloat = 16
        static let stepperSpacing: CGFloat = 128
        static let stepperTitleSpacing: CGFloat = 8
    }
}

final class EditMelodyViewController: UIViewController {
    private let viewModel: EditMelodyViewModelInput
    
    private let playButton = UIButton()
    
    private let toolbarView = UIView()
    private let beatsStepperTitle = UILabel()
    private let beatsStepper: ClassicStepper
    private let resolutionStepperTitle = UILabel()
    private let resolutionStepper: ClassicStepper
    
    private lazy var collectionView: UICollectionView  = {
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .imp.lightGray
        collectionView.register(
            MelodyKeyCollectionViewCell.self,
            forCellWithReuseIdentifier: MelodyKeyCollectionViewCell.reuseIdentifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    init(viewModel: EditMelodyViewModelInput) {
        self.viewModel = viewModel
        beatsStepper = .init(value: viewModel.getNumberOfBeats(), minimumValue: 1, maximumValue: 16)
        resolutionStepper = .init(value: viewModel.getResolution(), minimumValue: 1, maximumValue: 4)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configure()
        layout()
    }
    
    private func configure() {
        toolbarView.backgroundColor = .white

        beatsStepperTitle.text = "биты"
        beatsStepperTitle.role(.secondary)
        resolutionStepperTitle.text = "разрешение"
        resolutionStepperTitle.role(.secondary)
        
        navigationItem.titleView = playButton
        playButton.addTarget(self, action: #selector(onPlayButtonPressed(_:)), for: .touchUpInside)
        updatePlayButtonAppearance()
        
        navigationItem.leftBarButtonItem = .init(
            image: .init(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(onCloseButtonPressed(_:))
        )
    }
    
    private func layout() {
        [beatsStepper, beatsStepperTitle, resolutionStepper, resolutionStepperTitle].forEach {
            toolbarView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(toolbarView)
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            beatsStepper.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: Constants.stepperVerticalOffsets),
            resolutionStepperTitle.bottomAnchor.constraint(
                equalTo: toolbarView.safeAreaLayoutGuide.bottomAnchor,
                constant: -Constants.stepperVerticalOffsets
            ),
            
            resolutionStepper.centerYAnchor.constraint(equalTo: beatsStepper.centerYAnchor),
            resolutionStepper.leadingAnchor.constraint(equalTo: beatsStepper.trailingAnchor, constant: Constants.stepperSpacing),
            resolutionStepper.leadingAnchor.constraint(equalTo: toolbarView.centerXAnchor, constant: Constants.stepperSpacing / 2),
            
            beatsStepperTitle.centerXAnchor.constraint(equalTo: beatsStepper.centerXAnchor),
            resolutionStepperTitle.centerXAnchor.constraint(equalTo: resolutionStepper.centerXAnchor),
            beatsStepperTitle.topAnchor.constraint(equalTo: beatsStepper.bottomAnchor, constant: Constants.stepperTitleSpacing),
            resolutionStepperTitle.topAnchor.constraint(equalTo: resolutionStepper.bottomAnchor, constant: Constants.stepperTitleSpacing)
        ])
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor)
        ])
    }
    
    @objc 
    private func onPlayButtonPressed(_ sender: UIButton) {
        if viewModel.isPlaying {
            viewModel.stop()
        } else {
            viewModel.play()
        }
        updatePlayButtonAppearance()
    }
    
    private func updatePlayButtonAppearance() {
        playButton.setImage(
            .init(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill"),
            for: .normal
        )
        playButton.scaleImage(toWidth: 24)
    }
    
    @objc
    private func onCloseButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.onCloseButtonPressed()
    }
}

extension EditMelodyViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(
            width: Constants.keyWidth,
            height: collectionView.bounds.height / CGFloat(viewModel.getKeyboardSize())
        )
    }
}

extension EditMelodyViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.getKeySequence().count * viewModel.getKeyboardSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MelodyKeyCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? MelodyKeyCollectionViewCell
        
        return cell ?? UICollectionViewCell()
    }
}

extension EditMelodyViewController: EditMelodyViewModelOutput { }
