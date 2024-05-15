import Foundation
import UIKit

extension UserSearchViewController {
    private enum Constants {
        static let loadingIndicatorWrapperViewHeight: CGFloat = 32
        static let usersNotFoundLabelTopOffset: CGFloat = 16
        static let paginationUserMargin: Int = 5
    }
}

final class UserSearchViewController: UIViewController {
    private let viewModel: UserSearchViewModelInput

    private let searchController = UISearchController()
    private let loadingIndicator = UIActivityIndicatorView()
    private let loadingIndicatorWrapperView = UIView()
    private let usersNotFoundLabel = UILabel()

    private lazy var cancelButtonItem: UIBarButtonItem = .init(
        title: "Отмена",
        style: .plain,
        target: self,
        action: #selector(onCancelButtonTapped(_:))
    )

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.showsVerticalScrollIndicator = false
        tableView.insetsContentViewsToSafeArea = true
        tableView.register(
            UserSearchTableViewCell.self,
            forCellReuseIdentifier: UserSearchTableViewCell.reuseIdentifier
        )
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    init(viewModel: UserSearchViewModelInput) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Поиск"
        view.backgroundColor = .imp.backgroundColor
        configure()
        layout()
        viewModel.search(query: nil)
    }

    private func configure() {
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false

        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        tableView.tableFooterView = loadingIndicatorWrapperView

        usersNotFoundLabel.role(.secondary)
        usersNotFoundLabel.textColor = .secondaryLabel
        usersNotFoundLabel.text = "Пользователи не найдены"
        usersNotFoundLabel.isHidden = true
    }

    private func layout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        usersNotFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usersNotFoundLabel)
        usersNotFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usersNotFoundLabel.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: Constants.usersNotFoundLabelTopOffset
        ).isActive = true

        loadingIndicatorWrapperView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicatorWrapperView.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicatorWrapperView.widthAnchor.constraint(equalTo: tableView.widthAnchor),
            loadingIndicatorWrapperView.heightAnchor.constraint(equalToConstant: Constants.loadingIndicatorWrapperViewHeight),
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingIndicatorWrapperView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingIndicatorWrapperView.centerYAnchor)
        ])
    }

    @objc 
    private func onCancelButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.cancelButtonTapped()
    }
}

extension UserSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.userChosen(atIndex: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UserSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getUsers()?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row + Constants.paginationUserMargin > viewModel.getUsers()?.count ?? 0 {
            viewModel.loadMoreResults()
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: UserSearchTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? UserSearchTableViewCell

        if let user = viewModel.getUsers()?[indexPath.row] {
            cell?.setup(user: user)
        }

        return cell ?? UITableViewCell()
    }
}

extension UserSearchViewController: UserSearchViewModelOutput {
    func updateResults() {
        tableView.reloadData()
        tableView.tableFooterView?.isHidden = viewModel.getIsUsersFullyLoaded()
        if viewModel.getIsUsersFullyLoaded(), let users = viewModel.getUsers(), users.count == 0 {
            tableView.isHidden = true
            usersNotFoundLabel.isHidden = false
        } else {
            tableView.isHidden = false
            usersNotFoundLabel.isHidden = true
        }
    }
}

extension UserSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.search(query: searchController.searchBar.text)
    }
}
