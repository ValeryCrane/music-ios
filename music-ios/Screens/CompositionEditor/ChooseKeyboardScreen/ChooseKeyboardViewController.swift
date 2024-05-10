import Foundation
import UIKit

final class ChooseKeyboardViewController: UIViewController {
    private let viewModel: ChooseKeyboardViewModelInput

    private lazy var activityIndicator: UIActivityIndicatorView  = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            ChooseKeyboardTableViewCell.self,
            forCellReuseIdentifier: ChooseKeyboardTableViewCell.reuseIdentifier
        )
        tableView.delegate = self
        tableView.dataSource = self
        tableView.clipsToBounds = false
        return tableView
    }()

    init(viewModel: ChooseKeyboardViewModelInput) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .imp.backgroundColor
        configureNavigationItem()
        layout()
        
        viewModel.loadKeyboards()
    }

    private func configureNavigationItem() {
        title = "Клавиатуры"
        navigationItem.leftBarButtonItem = .init(
            title: "Отмена",
            style: .plain,
            target: self,
            action: #selector(onCancelButtonPressed(_:))
        )
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
        viewModel.onCancelButtonPressed()
    }
}

extension ChooseKeyboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getKeyboards()?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let keyboards = viewModel.getKeyboards() else { return UITableViewCell() }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChooseKeyboardTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ChooseKeyboardTableViewCell

        cell?.setup(
            isCurrent: keyboards[indexPath.row].id == viewModel.getCurrentKeyboard().id, 
            keyboard: keyboards[indexPath.row],
            state: viewModel.getStates()[indexPath.row],
            onPlayButtonPressed: { [weak self] in
                self?.viewModel.onPlayButtonPressed(atIndex: indexPath.row)
            }
        )

        return cell ?? UITableViewCell()
    }
}

extension ChooseKeyboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.onKeyboardChoosen(atIndex: indexPath.row)
    }
}

extension ChooseKeyboardViewController: ChooseKeyboardViewModelOutput {
    func updateKeyboards() {
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func updateState(atIndex index: Int, state: ChooseKeyboardTableViewCell.State) {
        let cell = tableView.cellForRow(
            at: .init(row: index, section: 0)
        ) as? ChooseKeyboardTableViewCell

        cell?.updateState(state)
    }
}
