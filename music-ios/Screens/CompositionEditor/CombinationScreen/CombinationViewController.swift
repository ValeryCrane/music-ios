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
        navigationItem.titleView = BPMStepper(value: 120, minimumValue: 30, maximumValue: 240)
    }
}

extension CombinationViewController: UITableViewDelegate {
    
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let view = AddRowTableFooterView(title: "Добавить сэмпл")
            return view
        case 1:
            let view = AddRowTableFooterView(title: "Добавить мелодию")
            return view
        default:
            return nil
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
            
            cell?.setup(sample: viewModel.getSamples()[indexPath.row])
            return cell ?? UITableViewCell()
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MelodyTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? MelodyTableViewCell
            
            cell?.setup(melody: viewModel.getMelodies()[indexPath.row])
            return cell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
}
