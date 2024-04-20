import Foundation
import UIKit

extension ChooseSampleViewController {
    private enum Constants {
        static let verticalOffsets: CGFloat = 16
        static let horizontalOffsets: CGFloat = 16
    }
}

final class ChooseSampleViewController: UIViewController {
    private let viewModel: ChooseSampleViewModelInput
    
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
            ChooseSampleTableViewCell.self,
            forCellReuseIdentifier: ChooseSampleTableViewCell.reuseIdentifier
        )
        tableView.dataSource = self
        return tableView
    }()
    
    init(viewModel: ChooseSampleViewModelInput) {
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
        viewModel.loadSamples()
    }
    
    private func configureNavigationItem() {
        title = "Сэмплы"
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

extension ChooseSampleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getSamples()?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let samples = viewModel.getSamples() else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChooseSampleTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ChooseSampleTableViewCell
        
        cell?.setup(
            sample: samples[indexPath.row],
            state: viewModel.getStates()[indexPath.row],
            onPlayButtonPressed: { [weak self] in
                self?.viewModel.onPlayButtonPressed(atIndex: indexPath.row)
            }
        )
        
        return cell ?? UITableViewCell()
    }
}

extension ChooseSampleViewController: ChooseSampleViewModelOutput {
    func updateSamples() {
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func updateState(atIndex index: Int, state: ChooseSampleTableViewCell.State) {
        let cell = tableView.cellForRow(
            at: .init(row: index, section: 0)
        ) as? ChooseSampleTableViewCell
        
        cell?.updateState(state)
    }
}
