import Foundation
import UIKit

extension RecordSampleViewController {
    private enum Constants {
        static let beatsInRow: Int = .beatsInMeasure
        static let horizontalOffsets: CGFloat = 16
        static let beatsHorizontalSpacing: CGFloat = 8
        static let beatsVerticalSpacing: CGFloat = 8
        static let beatsHeight: CGFloat = 8
        static let verticalOffsets: CGFloat = 16
        static let beatsStepperTitleOffset: CGFloat = 8
        static let buttonSpacing: CGFloat = 8
    }
}

extension RecordSampleViewController {
    enum State {
        case initial
        case recording
        case finished
    }
}

final class RecordSampleViewController: UIViewController {
    private let viewModel: RecordSampleViewModelInput

    private let measureStepperTitle = UILabel()
    private lazy var measureStepper = ClassicStepper(value: viewModel.getInitialMeasures(), minimumValue: 1, maximumValue: 8)

    private let recordButton = RecordSampleButton(
        icon: .init(systemName: "record.circle"),
        foregroundColor: .systemRed,
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
    
    private let clearButton = RecordSampleButton(
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
        measureStepperTitle.text = "такты"
        measureStepperTitle.role(.secondary)
        measureStepper.addTarget(self, action: #selector(measureStepperValueChanged(_:)), for: .valueChanged)
        navigationItem.leftBarButtonItem = .init(
            image: .init(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(onCloseButtonTapped(_:))
        )
        navigationItem.rightBarButtonItem = .init(
            image: .init(systemName: "slider.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(onEffectsButtonTapped(_:))
        )

        buttonStackView.axis = .horizontal
        buttonStackView.spacing = Constants.buttonSpacing
        buttonStackView.addArrangedSubview(recordButton)
        
        recordButton.addTarget(self, action: #selector(onRecordButtonTapped(_:)), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(onStopButtonTapped(_:)), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(onSaveButtonTapped(_:)), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(onPlayButtonTapped(_:)), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(onClearButtonTapped(_:)), for: .touchUpInside)
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
        
        view.addSubview(measureStepper)
        view.addSubview(measureStepperTitle)
        measureStepper.translatesAutoresizingMaskIntoConstraints = false
        measureStepperTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            measureStepper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.verticalOffsets),
            measureStepper.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            measureStepperTitle.centerXAnchor.constraint(equalTo: measureStepper.centerXAnchor),
            measureStepperTitle.topAnchor.constraint(equalTo: measureStepper.bottomAnchor, constant: Constants.beatsStepperTitleOffset)
        ])
        
        view.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalOffsets)
        ])
    }

    @objc
    private func onRecordButtonTapped(_ sender: RecordSampleButton) {
        viewModel.startButtonTapped()
    }

    @objc
    private func onStopButtonTapped(_ sender: RecordSampleButton) {
        viewModel.stopButtonTapped()
    }

    @objc
    private func measureStepperValueChanged(_ sender: ClassicStepper) {
        viewModel.setMeasures(sender.value)
        beatCollectionView.reloadData()
    }
    
    @objc
    private func onCloseButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.closeButtonTapped()
    }

    @objc
    private func onSaveButtonTapped(_ sender: UIButton) {
        viewModel.saveButtonTapped()
    }

    @objc
    private func onPlayButtonTapped(_ sender: RecordSampleButton) {
        viewModel.playButtonTapped()
    }

    @objc
    private func onClearButtonTapped(_ sender: UIButton) {
        viewModel.clearButtonTapped()
    }

    @objc
    private func onEffectsButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.effectsButtonTapped()
    }

    private func removeAllButtonsFromStackView() {
        for subview in buttonStackView.arrangedSubviews {
            buttonStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
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
        measureStepper.value * .beatsInMeasure
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BeatRecordCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? BeatRecordCollectionViewCell
        
        return cell ?? UICollectionViewCell()
    }
}

extension RecordSampleViewController: RecordSampleViewModelOutput {
    func setState(_ state: State) {
        removeAllButtonsFromStackView()

        switch state {
        case .initial:
            measureStepper.isEnabled = true
            buttonStackView.addArrangedSubview(recordButton)
        case .recording:
            measureStepper.isEnabled = false
            buttonStackView.addArrangedSubview(stopButton)
        case .finished:
            measureStepper.isEnabled = false
            buttonStackView.addArrangedSubview(clearButton)
            buttonStackView.addArrangedSubview(playButton)
            buttonStackView.addArrangedSubview(saveButton)
        }
    }
    
    func startAnimation(forBeat beat: Int, delay: TimeInterval, duration: TimeInterval) {
        let cell = beatCollectionView.cellForItem(
            at: .init(row: beat, section: 0)
        ) as? BeatRecordCollectionViewCell

        cell?.start(beatDuration: duration, delay: delay)
    }
    
    func finishAllAnimations() {
        for cell in beatCollectionView.visibleCells {
            let beatCell = cell as? BeatRecordCollectionViewCell
            beatCell?.stop()
        }
    }

    func resetAllAnimations() {
        for cell in beatCollectionView.visibleCells {
            let beatCell = cell as? BeatRecordCollectionViewCell
            beatCell?.reset()
        }
    }
}
