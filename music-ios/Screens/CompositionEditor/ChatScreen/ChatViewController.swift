import UIKit

extension ChatViewController {
    private enum Constants {
        static let sendButtonCornerRadius: CGFloat = 8
        static let tableViewBottomOffset: CGFloat = 16
        static let inputBottomOffset: CGFloat = 16
        static let inputHeight: CGFloat = 40
        static let horisontalOffsets: CGFloat = 16
        static let sendButtonSpacing: CGFloat = 8
        static let loadedMessagesPaginationMargin: Int = 10
    }
}

extension ChatViewController {
    private enum SendButtonState {
        case `default`
        case disabled
        case sending
    }
}

final class ChatViewController: UIViewController {
    private let viewModel: ChatViewModelInput

    private let sendActivityIndicatior = UIActivityIndicatorView()
    private let messagesActivityIndicator = UIActivityIndicatorView()

    private lazy var inputTextField: UITextField = {
        let inputTextField = UITextField()
        inputTextField.borderStyle = .roundedRect
        inputTextField.placeholder = "Введите сообщение..."
        inputTextField.delegate = self
        return inputTextField
    }()

    private lazy var sendButton: UIButton = {
        let sendButton = UIButton()
        sendButton.tintColor = .white
        sendButton.setImage(.init(systemName: "paperplane.fill"), for: .normal)
        sendButton.layer.cornerRadius = Constants.sendButtonCornerRadius
        sendButton.addTarget(self, action: #selector(onSendButtonTapped(_:)), for: .touchUpInside)
        return sendButton
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.reuseIdentifier)
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.dataSource = self
        return tableView
    }()

    private lazy var closeButtonItem: UIBarButtonItem = .init(
        image: .init(systemName: "xmark"),
        style: .plain,
        target: self,
        action: #selector(onCloseButtonTapped(_:))
    )

    private var withKeyboardConstraint: NSLayoutConstraint?
    private var withoutKeyboardConstraint: NSLayoutConstraint?

    init(viewModel: ChatViewModelInput) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Чат"
        view.backgroundColor = .white
        configure()
        layout()
        viewModel.viewDidLoad()
    }

    private func configure() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self, 
            selector: #selector(handleKeyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        navigationItem.leftBarButtonItem = closeButtonItem
        sendActivityIndicatior.hidesWhenStopped = true
        messagesActivityIndicator.hidesWhenStopped = true
        tableView.isHidden = true
        messagesActivityIndicator.startAnimating()
        setSendButtonState(.disabled)
    }

    private func layout() {
        let toolbarStackView = UIStackView(arrangedSubviews: [inputTextField, sendButton])
        toolbarStackView.axis = .horizontal
        toolbarStackView.spacing = Constants.sendButtonSpacing

        [tableView, toolbarStackView, messagesActivityIndicator].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendActivityIndicatior.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addSubview(sendActivityIndicatior)

        let withKeyboardConstraint = toolbarStackView.bottomAnchor.constraint(
            equalTo: view.keyboardLayoutGuide.topAnchor,
            constant: -Constants.inputBottomOffset
        )

        let withoutKeyboardConstraint = toolbarStackView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -Constants.inputBottomOffset
        )

        self.withKeyboardConstraint = withKeyboardConstraint
        self.withoutKeyboardConstraint = withoutKeyboardConstraint
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbarStackView.topAnchor, constant: -Constants.tableViewBottomOffset),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            withoutKeyboardConstraint,
            toolbarStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horisontalOffsets),
            toolbarStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horisontalOffsets),
            toolbarStackView.heightAnchor.constraint(equalToConstant: Constants.inputHeight),
            sendButton.heightAnchor.constraint(equalTo: sendButton.widthAnchor),

            sendActivityIndicatior.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            sendActivityIndicatior.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            messagesActivityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            messagesActivityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }

    private func setSendButtonState(_ state: SendButtonState) {
        switch state {
        case .default:
            sendButton.isEnabled = true
            sendButton.setImage(.init(systemName: "paperplane.fill"), for: .normal)
            sendButton.backgroundColor = .imp.primary
            self.sendActivityIndicatior.stopAnimating()
        case .disabled:
            sendButton.isEnabled = false
            sendButton.setImage(.init(systemName: "paperplane.fill"), for: .normal)
            sendButton.backgroundColor = .lightGray
            self.sendActivityIndicatior.stopAnimating()
        case .sending:
            sendButton.isEnabled = false
            sendButton.setImage(nil, for: .normal)
            sendButton.backgroundColor = .lightGray
            self.sendActivityIndicatior.startAnimating()
        }
    }

    @objc 
    private func handleKeyboardWillShow(_ notification: Notification) {
        withoutKeyboardConstraint?.isActive = false
        withKeyboardConstraint?.isActive = true
        view.layoutIfNeeded()
    }

    @objc
    private func handleKeyboardWillHide(_ notification: Notification) {
        withKeyboardConstraint?.isActive = false
        withoutKeyboardConstraint?.isActive = true
        view.layoutIfNeeded()
    }

    @objc
    private func onSendButtonTapped(_ sender: UIButton) {
        guard let message = inputTextField.text, !message.isEmpty else { return }
        
        inputTextField.isEnabled = false
        setSendButtonState(.sending)
        viewModel.onSend(message: message)
    }

    @objc 
    private func onCloseButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.closeButtonTapped()
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getMessages()?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ChatTableViewCell

        if let message = viewModel.getMessages()?[indexPath.row] {
            cell?.setup(chatMessage: message)
        }

        if indexPath.row > (viewModel.getMessages()?.count ?? 0) - Constants.loadedMessagesPaginationMargin {
            viewModel.needsMoreMessages()
        }

        cell?.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell ?? UITableViewCell()
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let oldText = textField.text {
            let newString = (oldText as NSString).replacingCharacters(in: range, with: string)
            if newString.isEmpty {
                setSendButtonState(.disabled)
            } else {
                setSendButtonState(.default)
            }
        } else {
            setSendButtonState(.disabled)
        }

        return true
    }
}

extension ChatViewController: ChatViewModelOutput {
    func updateMessages() {
        if viewModel.getMessages() != nil {
            messagesActivityIndicator.stopAnimating()
            tableView.reloadData()
            tableView.isHidden = false
        } else {
            messagesActivityIndicator.startAnimating()
            tableView.isHidden = true
        }
    }
    
    func stopSendMessageLoader() {
        inputTextField.isEnabled = true
        inputTextField.text = nil
        setSendButtonState(.disabled)
        tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
    }
}
