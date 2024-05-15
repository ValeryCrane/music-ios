import Foundation
import UIKit

protocol ChatViewModelInput {
    func viewDidLoad()
    func needsMoreMessages()
    func onSend(message: String)

    func getMessages() -> [ChatMessage]?
    func getIsLoadedCompletely() -> Bool
    func closeButtonTapped()
}

protocol ChatViewModelOutput: UIViewController {
    func updateMessages()
    func stopSendMessageLoader()
}

final class ChatViewModel {
    weak var view: ChatViewModelOutput?

    private let chatManager: ChatManager

    private var messageSubscription: Task<Void, Never>?
    private var messageLoadTask: Task<Void, Error>?

    init(chatManager: ChatManager) {
        self.chatManager = chatManager
    }

    deinit {
        messageSubscription?.cancel()
    }

    private func loadMoreMessages() {
        guard messageLoadTask == nil else { return }

        messageLoadTask = Task {
            try await chatManager.load()
            await MainActor.run {
                view?.updateMessages()
            }

            subscribeOnNewMessages()
            messageLoadTask = nil
        }
    }

    private func subscribeOnNewMessages() {
        guard messageSubscription == nil else { return }

        messageSubscription = Task {
            while !Task.isCancelled {
                do {
                    try await chatManager.loadNextMessages()
                    await MainActor.run {
                        view?.updateMessages()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension ChatViewModel: ChatViewModelInput {
    func viewDidLoad() {
        loadMoreMessages()
    }
    
    func needsMoreMessages() {
        if !chatManager.isFullyLoaded {
            loadMoreMessages()
        }
    }
    
    func onSend(message: String) {
        Task {
            try await chatManager.send(message: message)

            await MainActor.run {
                view?.stopSendMessageLoader()
            }
        }
    }
    
    func getMessages() -> [ChatMessage]? {
        chatManager.messages
    }
    
    func getIsLoadedCompletely() -> Bool {
        chatManager.isFullyLoaded
    }

    func closeButtonTapped() {
        view?.dismiss(animated: true)
    }
}
