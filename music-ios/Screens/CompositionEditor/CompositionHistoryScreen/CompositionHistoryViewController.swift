import Foundation
import UIKit

final class CompositionHistoryViewController: UIViewController {
    private let viewModel: CompositionHistoryViewModelInput

    private let activityIndicator = UIActivityIndicatorView()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.insetsContentViewsToSafeArea = true
        tableView.register(
            CompositionHistoryEventTableViewCell.self,
            forCellReuseIdentifier: CompositionHistoryEventTableViewCell.reuseIdentifier
        )
        tableView.dataSource = self
        return tableView
    }()

    init(viewModel: CompositionHistoryViewModelInput) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "История изменений"
        view.backgroundColor = .imp.backgroundColor
        configure()
        layout()

        viewModel.loadHistory()
    }

    private func configure() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        tableView.isHidden = true
    }

    private func layout() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension CompositionHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getHistoryEvents()?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CompositionHistoryEventTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? CompositionHistoryEventTableViewCell

        if let historyEvent = viewModel.getHistoryEvents()?[indexPath.row] {
            cell?.setup(
                compositionHistoryEvent: historyEvent,
                isFirst: indexPath.row == 0,
                isLast: indexPath.row + 1 == (viewModel.getHistoryEvents()?.count ?? 0)
            )
        }

        return cell ?? UITableViewCell()
    }
}

extension CompositionHistoryViewController: CompositionHistoryViewModelOutput {
    func updateHistoryEvents() {
        tableView.reloadData()
        tableView.isHidden = false
        activityIndicator.stopAnimating()
    }
}
