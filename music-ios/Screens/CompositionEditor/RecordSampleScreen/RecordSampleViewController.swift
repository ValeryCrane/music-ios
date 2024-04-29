import Foundation
import UIKit

extension RecordSampleViewController {
    private enum Constants {
        static let beatsInRow: Int = 4
        static let horizontalOffsets: CGFloat = 16
        static let beatsHorizontalSpacing: CGFloat = 8
        static let beatsVerticalSpacing: CGFloat = 8
        static let beatsHeight: CGFloat = 8
        static let verticalOffsets: CGFloat = 16
        static let beatsStepperTitleOffset: CGFloat = 8
        static let buttonSpacing: CGFloat = 8
    }
}

final class RecordSampleViewController: UIViewController {
    private let viewModel: RecordSampleViewModelInput
    
    private let beatStepper = ClassicStepper(value: 4, minimumValue: 1, maximumValue: 32)
    private let beatStepperTitle = UILabel()
    
    private let recordButton = RecordSampleButton(
        icon: .init(systemName: "record.circle"),
        foregroundColor: .systemRed,
        backgroundColor: .imp.lightGray
    )
    
    private let pauseButton = RecordSampleButton(
        icon: .init(systemName: "pause.fill"),
        foregroundColor: .darkGray,
        backgroundColor: .imp.lightGray
    )
    
    private let stopButton = RecordSampleButton(
        icon: .init(systemName: "stop.fill"),
        foregroundColor: .white,
        backgroundColor: .systemRed
    )
    
    private let saveButton = RecordSampleButton(
        icon: .init(systemName: "square.and.arrow.down"),
        foregroundColor: .white,
        backgroundColor: .imp.primary
    )
    
    private let playButton = RecordSampleButton(
        icon: .init(systemName: "play.fill"),
        foregroundColor: .darkGray,
        backgroundColor: .imp.lightGray
    )
    
    private let deleteButton = RecordSampleButton(
        icon: .init(systemName: "trash.fill"),
        foregroundColor: .white,
        backgroundColor: .systemRed
    )
    
    private let buttonStackView = UIStackView()
    
    private lazy var beatCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Constants.beatsVerticalSpacing
        layout.minimumInteritemSpacing = Constants.beatsVerticalSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsSelection = false
        collectionView.register(
            BeatRecordCollectionViewCell.self,
            forCellWithReuseIdentifier: BeatRecordCollectionViewCell.reuseIdentifier
        )
        
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    init(viewModel: RecordSampleViewModelInput) {
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
        configure()
        layout()
    }
    
    private func configure() {
        title = "Запись"
        beatStepperTitle.text = "биты"
        beatStepperTitle.role(.secondary)
        beatStepper.addTarget(self, action: #selector(beatStepperValueChanged(_:)), for: .valueChanged)
        navigationItem.leftBarButtonItem = .init(
            image: .init(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(onCloseButtonPressed(_:))
        )
        
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = Constants.buttonSpacing
        buttonStackView.addArrangedSubview(recordButton)
        
        recordButton.addTarget(self, action: #selector(onPlayButtonPressed(_:)), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(onStopButtonPressed(_:)), for: .touchUpInside)
    }
    
    private func layout() {
        view.addSubview(beatCollectionView)
        beatCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            beatCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            beatCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalOffsets),
            beatCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalOffsets),
            beatCollectionView.heightAnchor.constraint(equalToConstant: 128)
        ])
        
        view.addSubview(beatStepper)
        view.addSubview(beatStepperTitle)
        beatStepper.translatesAutoresizingMaskIntoConstraints = false
        beatStepperTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            beatStepper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.verticalOffsets),
            beatStepper.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            beatStepperTitle.centerXAnchor.constraint(equalTo: beatStepper.centerXAnchor),
            beatStepperTitle.topAnchor.constraint(equalTo: beatStepper.bottomAnchor, constant: Constants.beatsStepperTitleOffset)
        ])
        
        view.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalOffsets)
        ])
    }
    
    @objc
    private func beatStepperValueChanged(_ sender: ClassicStepper) {
        beatCollectionView.reloadData()
    }
    
    @objc
    private func onCloseButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.onCloseButtonPressed()
    }
    
    @objc
    private func onPlayButtonPressed(_ sender: RecordSampleButton) {
        startRecordingAnimation()
        showRecordingButtons()
        viewModel.startRecording(beats: beatStepper.value)
    }
    
    @objc
    private func onStopButtonPressed(_ sender: RecordSampleButton) {
        showFinishButtons()
    }
    
    private func startRecordingAnimation() {
        for i in 0 ..< beatStepper.value {
            let cell = beatCollectionView.cellForItem(
                at: .init(row: i, section: 0)
            ) as? BeatRecordCollectionViewCell
            
            cell?.start(beatDuration: 0.5, delay: 0.5 * Double(i))
        }
    }
    
    private func showRecordingButtons() {
        buttonStackView.removeArrangedSubview(recordButton)
        recordButton.removeFromSuperview()
        buttonStackView.addArrangedSubview(pauseButton)
        buttonStackView.addArrangedSubview(stopButton)
    }
    
    private func showFinishButtons() {
        buttonStackView.removeArrangedSubview(pauseButton)
        buttonStackView.removeArrangedSubview(stopButton)
        pauseButton.removeFromSuperview()
        stopButton.removeFromSuperview()
        
        buttonStackView.addArrangedSubview(deleteButton)
        buttonStackView.addArrangedSubview(playButton)
        buttonStackView.addArrangedSubview(saveButton)
    }
    
}

extension RecordSampleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalWidth = collectionView.bounds.width
        let spacing = Constants.beatsHorizontalSpacing * CGFloat(Constants.beatsInRow - 1)
        return .init(
            width: (totalWidth - spacing) / CGFloat(Constants.beatsInRow),
            height: Constants.beatsHeight
        )
    }
}

extension RecordSampleViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        beatStepper.value
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BeatRecordCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? BeatRecordCollectionViewCell
        
        return cell ?? UICollectionViewCell()
    }
}

extension RecordSampleViewController: RecordSampleViewModelOutput { }
