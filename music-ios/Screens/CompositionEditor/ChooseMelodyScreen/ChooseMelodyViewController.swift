import Foundation
import UIKit

extension ChooseMelodyViewController {
    private enum Constants {
        static let verticalOffsets: CGFloat = 16
        static let horizontalOffsets: CGFloat = 16
    }
}

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
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(
            ChooseMelodyTableViewCell.self,
            forCellReuseIdentifier: ChooseMelodyTableViewCell.reuseIdentifier
        )
        tableView.dataSource = self
        return tableView
    }()
    
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
    
    private func configureNavigationItem() {
        title = "Мелодии"
        navigationItem.leftBarButtonItem = .init(
            title: "Отмена",
            style: .plain,
            target: self,
            action: #selector(onCancelButtonPressed(_:))
        )
        navigationItem.rightBarButtonItem = .init(
            title: "Создать",
            style: .done,
            target: self,
            action: #selector(onCreateButtonPressed(_:))
        )
    }
    
    private func layout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.verticalOffsets),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalOffsets),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalOffsets),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalOffsets),
            
            activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
    
    @objc
    private func onCancelButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.onCancelButtonPressed()
    }
    
    @objc
    private func onCreateButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.onCreateButtonPressed()
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
                self?.viewModel.onPlayButtonPressed(atIndex: indexPath.row)
            }
        )
        
        return cell ?? UITableViewCell()
    }
}

extension ChooseMelodyViewController: ChooseMelodyViewModelOutput {
    func updateMelodies() {
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func updateState(atIndex index: Int, state: ChooseMelodyTableViewCell.State) {
        let cell = tableView.cellForRow(
            at: .init(row: index, section: 0)
        ) as? ChooseMelodyTableViewCell
        
        cell?.updateState(state)
    }
}
