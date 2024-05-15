import Foundation

final class ChatManager {
    private(set) var messages: [ChatMessage]? = nil
    private(set) var isFullyLoaded: Bool = false

    private let compositionChat = Requests.CompositionChat()
    private let compositionChatLoad = Requests.CompositionChatLoad()
    private let compositionChatSend = Requests.CompositionChatSend()

    private let compositionId: Int

    private var subscriptionTask: Task<Void, Never>?

    init(compositionId: Int) {
        self.compositionId = compositionId
    }

    func load() async throws {
        if let messages = messages {
            if !isFullyLoaded, let lastMessage = messages.last {
                let messagesResponse = try await compositionChatLoad.run(with: .init(firstMessageId: lastMessage.id, compositionId: compositionId))
                let messages: [ChatMessage] = messagesResponse.messages.map({ .init(from: $0) })
                self.messages?.append(contentsOf: messages)
                self.isFullyLoaded = messagesResponse.isLastBatch
            }
        } else {
            let messagesResponse = try await compositionChatLoad.run(with: .init(firstMessageId: nil, compositionId: compositionId))
            messages = messagesResponse.messages.map({ .init(from: $0) })
            isFullyLoaded = messagesResponse.isLastBatch
        }
    }

    func send(message: String) async throws {
        try await compositionChatSend.run(with: .init(compositionId: compositionId, message: message))
    }

    func loadNextMessages() async throws {
        guard let messages = messages else { return }

        let messageResponse = try await compositionChat.run(with: .init(
            compositionId: compositionId,
            lastMessageId: messages.first?.id
        ))

        self.messages?.insert(contentsOf: messageResponse.messages.map({ .init(from: $0) }), at: 0)
    }
}
