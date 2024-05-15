import Foundation
import UIKit

extension CompositionParametersViewController {
    private enum Constants {
        static let horizontalOffsets: CGFloat = 16
        static let cellSpacing: CGFloat = 12
    }
}

final class CompositionParametersViewController: UIViewController {
    private let viewModel: CompositionParametersViewModelInput

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.insetsContentViewsToSafeArea = true
        tableView.register(
            CompositionVisibilityTableViewCell.self,
            forCellReuseIdentifier: CompositionVisibilityTableViewCell.reuseIdentifier
        )
        tableView.register(
            CompositionUserMiniatureTableViewCell.self,
            forCellReuseIdentifier: CompositionUserMiniatureTableViewCell.reuseIdentifier
        )
        tableView.register(
            CompositionNameTableViewCell.self,
            forCellReuseIdentifier: CompositionNameTableViewCell.reuseIdentifier
        )
        tableView.register(
            CompositionDeleteTableViewCell.self,
            forCellReuseIdentifier: CompositionDeleteTableViewCell.reuseIdentifier
        )
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var historyButtonItem: UIBarButtonItem = .init(
        image: .init(systemName: "clock.arrow.circlepath"),
        style: .plain,
        target: self, 
        action: #selector(onHistoryButtonTapped(_:))
    )

    init(viewModel: CompositionParametersViewModelInput) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Параметры"
        view.backgroundColor = .imp.backgroundColor
        navigationItem.rightBarButtonItem = historyButtonItem

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc
    private func onHistoryButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.historyButtonTapped()
    }

    @objc
    private func onAddEditorButtonTapped(_ sender: AddRowTableFooterView) {
        viewModel.addEditorButtonTapped()
    }
}

extension CompositionParametersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 3:
            let view = AddRowTableFooterView(title: "Добавить редактора")
            view.addTarget(self, action: #selector(onAddEditorButtonTapped(_:)), for: .touchUpInside)
            return view
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 3:
            56
        default:
            0
        }
    }
}

extension CompositionParametersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            "Название композиции"
        case 1:
            "Видимость"
        case 2:
            "Создатель"
        case 3:
            "Редакторы"
        case 4:
            "Дополнительно"
        default:
            nil
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 3:
            viewModel.getEditors().count
        default:
            1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isCellLast = tableView.numberOfRows(inSection: indexPath.section) == indexPath.row + 1
        let cellInsets = UIEdgeInsets(
            top: 0,
            left: Constants.horizontalOffsets,
            bottom: isCellLast ? 0 : Constants.cellSpacing,
            right: Constants.horizontalOffsets
        )

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CompositionNameTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? CompositionNameTableViewCell

            cell?.setup(name: viewModel.getName())
            cell?.insets = cellInsets

            return cell ?? UITableViewCell()
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CompositionVisibilityTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? CompositionVisibilityTableViewCell

            cell?.setup(visibility: viewModel.getVisibility(), onChangeButtonTapped: { [weak self] in
                self?.viewModel.changeVisibilityButtonTapped()
            })
            cell?.insets = cellInsets

            return cell ?? UITableViewCell()
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CompositionUserMiniatureTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? CompositionUserMiniatureTableViewCell

            cell?.setup(user: viewModel.getCreator())
            cell?.insets = cellInsets

            return cell ?? UITableViewCell()
        case 3:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CompositionUserMiniatureTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? CompositionUserMiniatureTableViewCell

            cell?.setup(user: viewModel.getEditors()[indexPath.row], onLongTap: { [weak self] in
                self?.viewModel.editorLongTapped(atIndex: indexPath.row)
            })
            cell?.insets = cellInsets

            return cell ?? UITableViewCell()
        case 4:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CompositionDeleteTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? CompositionDeleteTableViewCell

            cell?.setup(onDeleteButtonTapped: { [weak self] in
                self?.viewModel.deleteButtonTapped()
            })
            cell?.insets = cellInsets

            return cell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
}

extension CompositionParametersViewController: CompositionParametersViewModelOutput {
    func updateName() {
        let cell = tableView.cellForRow(at: .init(row: 0, section: 0)) as? CompositionNameTableViewCell
        cell?.setup(name: viewModel.getName())
    }
    
    func updateVisibility() {
        let cell = tableView.cellForRow(at: .init(row: 0, section: 1)) as? CompositionVisibilityTableViewCell
        cell?.update(visibility: viewModel.getVisibility())
    }
    
    func updateEditors() {
        tableView.reloadData()
    }
}

