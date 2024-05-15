import Foundation
import UIKit

struct ChatMessage {
    let id: Int
    let username: String
    let text: String
    let isOwn: Bool
    let date: Date
}

extension ChatMessage {
    init(from messageResponse: MessageResponse) {
        self.init(
            id: messageResponse.id,
            username: messageResponse.user.username,
            text: messageResponse.text,
            isOwn: messageResponse.isOwn,
            date: .init(timeIntervalSince1970: TimeInterval(messageResponse.unixTime))
        )
    }
}
