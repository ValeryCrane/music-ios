import Foundation
import UIKit

final class ChooseMelodyViewController: UIViewController {
    private let viewModel: ChooseMelodyViewModelInput
    
    private lazy var activityIndicator: UIActivityIndicatorView  = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            ChooseMelodyTableViewCell.self,
            forCellReuseIdentifier: ChooseMelodyTableViewCell.reuseIdentifier
        )
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        return tableView
    }()

    private lazy var cancelButtonItem = UIBarButtonItem(
        title: "Отмена",
        style: .plain,
        target: self,
        action: #selector(onCancelButtonPressed(_:))
    )

    private lazy var createButtonItem = UIBarButtonItem(
        title: "Создать",
        style: .done,
        target: self,
        action: #selector(onCreateButtonPressed(_:))
    )

    init(viewModel: ChooseMelodyViewModelInput) {
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
        viewModel.loadMelodies()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        viewModel.viewDidDisappear()
    }

    private func configureNavigationItem() {
        title = "Мелодии"
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem = createButtonItem
    }
    
    private func layout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
    
    @objc
    private func onCancelButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.cancelButtonTapped()
    }
    
    @objc
    private func onCreateButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.createButtonTapped()
    }
}

extension ChooseMelodyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.melodyChosen(atIndex: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ChooseMelodyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getMelodies()?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let melodies = viewModel.getMelodies() else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChooseMelodyTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ChooseMelodyTableViewCell
        
        cell?.setup(
            melody: melodies[indexPath.row],
            state: viewModel.getStates()[indexPath.row],
            onPlayButtonPressed: { [weak self] in
                self?.viewModel.playButtonTapped(atIndex: indexPath.row)
            }
        )
        
        return cell ?? UITableViewCell()
    }
}

extension ChooseMelodyViewController: ChooseMelodyViewModelOutput {
    func showLoader() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
    }

    func setButtonsState(isEnabled: Bool) {
        cancelButtonItem.isEnabled = isEnabled
        createButtonItem.isEnabled = isEnabled
    }

    func updateMelodies() {
        activityIndicator.stopAnimating()
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    func updateState(atIndex index: Int, state: ChooseMelodyTableViewCell.State) {
        let cell = tableView.cellForRow(
            at: .init(row: index, section: 0)
        ) as? ChooseMelodyTableViewCell
        
        cell?.updateState(state)
    }
}
