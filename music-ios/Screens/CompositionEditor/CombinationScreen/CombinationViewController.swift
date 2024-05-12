import Foundation
import UIKit

extension CombinationViewController {
    private enum Constants {
        static let horizontalOffsets: CGFloat = 16
        static let verticalOffsets: CGFloat = 16
    }
}

final class CombinationViewController: UIViewController {
    
    private let viewModel: CombinationViewModelInput
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(MelodyTableViewCell.self, forCellReuseIdentifier: MelodyTableViewCell.reuseIdentifier)
        tableView.register(SampleTableViewCell.self, forCellReuseIdentifier: SampleTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var playButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setImage(.init(
            systemName: viewModel.getInitialPlayButtonState() ? "pause.fill" : "play.fill"
        ), for: .normal)
        button.addTarget(self, action: #selector(onPlayButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var effectsButtonItem: UIBarButtonItem = .init(
        image: .init(systemName: "slider.horizontal.3"),
        style: .plain,
        target: self,
        action: #selector(onEffectsButtonTapped(_:))
    )

    init(viewModel: CombinationViewModelInput) {
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
        configureNavigationItem()
        layout()
    }
    
    private func layout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.verticalOffsets),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalOffsets),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalOffsets),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalOffsets),
        ])
    }
    
    private func configureNavigationItem() {
        navigationItem.titleView = playButton
        navigationItem.rightBarButtonItem = effectsButtonItem
    }
    
    @objc
    private func onAddMelodyButtonTapped(_ sender: AddRowTableFooterView) {
        viewModel.addMelodyButtonTapped()
    }

    @objc
    private func onAddSampleButtonTapped(_ sender: AddRowTableFooterView) {
        viewModel.addSampleButtonTapped()
    }

    @objc
    private func onPlayButtonTapped(_ sender: UIButton) {
        viewModel.playButtonTapped()
    }

    @objc
    private func onEffectsButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.effectsButtonTapped()
    }
}

extension CombinationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let view = AddRowTableFooterView(title: "Добавить сэмпл")
            view.addTarget(self, action: #selector(onAddSampleButtonTapped(_:)), for: .touchUpInside)
            return view
        case 1:
            let view = AddRowTableFooterView(title: "Добавить мелодию")
            view.addTarget(self, action: #selector(onAddMelodyButtonTapped(_:)), for: .touchUpInside)
            return view
        default:
            return nil
        }
    }
}

extension CombinationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            "Сэмплы"
        case 1:
            "Мелодии"
        default:
            nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        56
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            viewModel.getSamples().count
        case 1:
            viewModel.getMelodies().count
        default:
            0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SampleTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? SampleTableViewCell

            cell?.setup(
                sampleMiniature: viewModel.getSamples()[indexPath.row],
                onMuteButtonTapped: { [weak self] in
                    self?.viewModel.muteButtonTapped(atSampleIndex: indexPath.row)
                },
                onEffectsButtonTapped: { [weak self] in
                    self?.viewModel.effectsButtonTapped(atSampleIndex: indexPath.row)
                }
            )

            return cell ?? UITableViewCell()
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MelodyTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? MelodyTableViewCell
            
            cell?.setup(
                melodyMiniature: viewModel.getMelodies()[indexPath.row],
                onEditButtonTapped: { [weak self] in
                    self?.viewModel.editButtonTapped(atMelodyIndex: indexPath.row)
                },
                onMuteButtonTapped: { [weak self] in
                    self?.viewModel.muteButtonTapped(atMelodyIndex: indexPath.row)
                },
                onEffectsButtonTapped: { [weak self] in
                    self?.viewModel.effectsButtonTapped(atMelodyIndex: indexPath.row)
                }
            )
            
            return cell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
}

extension CombinationViewController: CombinationViewModelOutput {
    func updateMelodiesAndSamples() {
        tableView.reloadData()
    }
    
    func updateSample(atIndex index: Int, sampleMiniature: CombinationSampleMiniature) {
        let cell = tableView.cellForRow(at: .init(row: index, section: 0)) as? SampleTableViewCell
        cell?.update(sampleMiniature: sampleMiniature)
    }
    
    func updateMelody(atIndex index: Int, melodyMiniature: CombinationMelodyMiniature) {
        let cell = tableView.cellForRow(at: .init(row: index, section: 1)) as? MelodyTableViewCell
        cell?.update(melodyMiniature: melodyMiniature)
    }
    
    func updatePlayButtonState(isPlaying: Bool) {
        playButton.setImage(.init(systemName: isPlaying ? "pause.fill" : "play.fill"), for: .normal)
    }
}
