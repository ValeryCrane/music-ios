import Foundation
import UIKit

extension EditMelodyViewController {
    private enum Constants {
        static let pedalButtonVerticalInsets: CGFloat = 2
        static let pedalButtonHorizontalInsets: CGFloat = 4
        static let pedalButtonCornerRadius: CGFloat = 4
        static let playIndicatorWidth: CGFloat = 1
        static let pedalButtonAnimationDuration: TimeInterval = 0.2
    }
}

final class EditMelodyViewController: UIViewController {
    private let viewModel: EditMelodyViewModelInput

    // MARK: Views

    private let grid: EditMelodyGrid
    private let gridScrollView = UIScrollView()
    private let activityIndicator = UIActivityIndicatorView()

    private let playIndicator = UIView()
    private var playIndicatorDisplayLink: CADisplayLink?

    // MARK: Navigation and toolbar items

    private lazy var resolutionButtonItem = UIBarButtonItem(title: resolution.fractionTitle, menu: resolutionMenu)
    private lazy var measuresButtonItem = UIBarButtonItem(title: "\(viewModel.getInitialMeasures()) тактов", menu: measuresMenu)

    private lazy var playButtonItem = UIBarButtonItem(
        image: .init(systemName: "play.fill"),
        style: .done,
        target: self,
        action: #selector(onPlayButtonTapped(_:))
    )

    private lazy var effectsButtonItem = UIBarButtonItem(
        image: .init(systemName: "slider.horizontal.3"),
        style: .plain,
        target: self,
        action: #selector(onEffectsButtonTapped(_:))
    )

    private lazy var chooseKeyboardButtonItem = UIBarButtonItem(
        image: .init(systemName: "pianokeys"),
        style: .plain,
        target: self,
        action: #selector(onChooseKeyboardButtonTapped(_:))
    )

    private lazy var doneButtonItem = UIBarButtonItem(
        title: "Готово",
        style: .done,
        target: self, 
        action: #selector(onDoneButtonTapped(_:))
    )

    private lazy var pedalButtonItem = UIBarButtonItem(customView: pedalButton)
    private lazy var pedalButton: UIButton = {
        var buttonConfiguration = UIButton.Configuration.plain()
        buttonConfiguration.contentInsets = .init(
            top: Constants.pedalButtonVerticalInsets,
            leading: Constants.pedalButtonHorizontalInsets,
            bottom: Constants.pedalButtonVerticalInsets,
            trailing: Constants.pedalButtonHorizontalInsets
        )
        let button = UIButton(configuration: buttonConfiguration, primaryAction: nil)
        button.setTitle("Pedal", for: .normal)
        button.addTarget(self, action: #selector(onPedalButtonTapped(_:)), for: .touchUpInside)
        button.layer.cornerRadius = Constants.pedalButtonCornerRadius
        return button
    }()

    // MARK: Menus

    private lazy var resolutionMenu: UIMenu = {
        let menuItems: [UIAction] = MelodyResolution.allCases.map { resolution in
            .init(title: resolution.title, image: resolution.image) { [weak self] _ in
                self?.resolution = resolution
            }
        }
        return .init(children: menuItems)
    }()
    
    private lazy var measuresMenu: UIMenu = {
        let menuItems: [UIAction] = (1 ... viewModel.getMaxMeasures()).map { measures in
            .init(title: "\(measures) тактов") { [weak self] _ in
                self?.viewModel.setMeasures(measures)
            }
        }
        return .init(children: menuItems)
    }()

    // MARK: Private properties

    private var resolution: MelodyResolution = .standart {
        didSet {
            grid.notesInBeat = resolution.notesInBeat
        }
    }

    // MARK: Init

    init(viewModel: EditMelodyViewModelInput) {
        self.viewModel = viewModel
        self.grid = .init(
            measures: viewModel.getInitialMeasures(),
            keys: viewModel.getInitialKeyboardSize(),
            notesInBeat: resolution.notesInBeat
        )

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController's life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .imp.backgroundColor
        configure()
        layout()

        for noteViewModel in viewModel.getInitialNotes() {
            createNote(noteViewModel: noteViewModel)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let gridScrollViewContentWidth = max(gridScrollView.frame.width, grid.intrinsicContentSize.width)
        let gridScrollViewContentHeight = max(gridScrollView.frame.height, grid.intrinsicContentSize.height)
        gridScrollView.contentSize = .init(width: gridScrollViewContentWidth, height: gridScrollViewContentHeight)
        if gridScrollView.frame.height > grid.intrinsicContentSize.height {
            grid.frame = .init(
                origin: .init(x: 0, y: (gridScrollView.bounds.height - grid.intrinsicContentSize.height) / 2),
                size: grid.intrinsicContentSize
            )
        } else {
            grid.frame = .init(origin: .zero, size: grid.intrinsicContentSize)
        }
    }

    // MARK: Private functions

    private func configure() {
        configureNavigationAndToolbarItems()

        gridScrollView.showsVerticalScrollIndicator = false
        gridScrollView.showsHorizontalScrollIndicator = false
        grid.delegate = self

        activityIndicator.hidesWhenStopped = true
        playIndicator.backgroundColor = .imp.primary
        playIndicator.isHidden = true
    }
    
    private func configureNavigationAndToolbarItems() {
        navigationItem.leftBarButtonItems = [effectsButtonItem, chooseKeyboardButtonItem, pedalButtonItem]
        navigationItem.rightBarButtonItem = doneButtonItem
        setToolbarItems([
            resolutionButtonItem, .flexibleSpace(), playButtonItem, .flexibleSpace(), measuresButtonItem
        ], animated: false)
        navigationController?.setToolbarHidden(false, animated: false)
        updatePedalButton(isActive: viewModel.getInitialPedalState())
    }
    
    private func layout() {
        gridScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridScrollView)
        NSLayoutConstraint.activate([
            gridScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            gridScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gridScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gridScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        gridScrollView.addSubview(grid)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: gridScrollView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: gridScrollView.centerYAnchor)
        ])

        gridScrollView.addSubview(playIndicator)
    }

    private func updatePedalButton(isActive: Bool) {
        if isActive {
            pedalButton.backgroundColor = navigationController?.navigationBar.tintColor
            pedalButton.tintColor = .white
        } else {
            pedalButton.tintColor = navigationController?.navigationBar.tintColor
            pedalButton.backgroundColor = .clear
        }
    }

    // MARK: Actions

    @objc 
    private func onPlayButtonTapped(_ sender: UIButton) {
        viewModel.onPlayButtonTapped()
    }

    @objc
    private func onPedalButtonTapped(_ sender: UIButton) {
        viewModel.onPedalButtonTapped()
    }

    @objc
    private func onEffectsButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.onEffectsButtonTapped()
    }

    @objc
    private func onChooseKeyboardButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.onChooseKeyboardButtonTapped()
    }

    @objc
    private func onDoneButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.onDoneButtonTapped()
    }

    @objc
    private func updatePlayIndicator(_ sender: CADisplayLink) {
        playIndicator.frame.origin.x = gridScrollView.contentSize.width * viewModel.getPlayIndicatorPosition()
    }
}

// MARK: - EditMelodyViewModelOutput

extension EditMelodyViewController: EditMelodyViewModelOutput {
    func loadingStarted() {
        gridScrollView.isHidden = true
        activityIndicator.startAnimating()
    }

    func loadingCompleted() {
        activityIndicator.stopAnimating()
        gridScrollView.isHidden = false
    }

    func updateMeasures(_ measures: Int) {
        measuresButtonItem.title = "\(measures) тактов"
        grid.measures = measures
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func updateKeyboardSize(_ keyboardSize: Int) {
        grid.keys = keyboardSize
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func updatePlayButtonState(isPlaying: Bool) {
        playButtonItem.image = .init(systemName: isPlaying ? "stop.fill" : "play.fill")
    }
    
    func updatePedalButtonState(isActive: Bool) {
        UIView.animate(withDuration: Constants.pedalButtonAnimationDuration) {
            self.updatePedalButton(isActive: isActive)
        }
    }
    
    func createNote(noteViewModel: NoteViewModel) {
        grid.addNote(noteViewModel: noteViewModel)
    }
    
    func deleteNote(noteViewModel: NoteViewModel) {
        grid.deleteNote(noteViewModel: noteViewModel)
    }
    
    func showPlayAnimation(note: NoteViewModel) {
        grid.startPlayAnimation(onNote: note)
    }

    func startPlayIndicator() {
        playIndicator.isHidden = false
        playIndicator.frame = .init(
            origin: .init(x: -Constants.playIndicatorWidth, y: 0),
            size: .init(width:  Constants.playIndicatorWidth, height: gridScrollView.contentSize.height)
        )
        
        playIndicatorDisplayLink = CADisplayLink(target: self, selector: #selector(updatePlayIndicator(_:)))
        playIndicatorDisplayLink?.add(to: .current, forMode: .common)
    }

    func removePlayIndicator() {
        playIndicator.isHidden = true
        playIndicatorDisplayLink?.invalidate()
        playIndicatorDisplayLink = nil
    }
}

// MARK: - EditMelodyGridDelegate

extension EditMelodyViewController: EditMelodyGridDelegate {
    func editMelodyGrid(_ editMelodyGrid: EditMelodyGrid, didCreateNote noteViewModel: NoteViewModel) {
        viewModel.createNote(noteViewModel: noteViewModel)
    }
    
    func editMelodyGrid(_ editMelodyGrid: EditMelodyGrid, didDeleteNote noteViewModel: NoteViewModel) {
        viewModel.deleteNote(noteViewModel: noteViewModel)
    }
}
