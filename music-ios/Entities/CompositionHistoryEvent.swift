import Foundation

struct CompositionHistoryEvent {
    let blueprintId: Int
    let creator: User
    let timeCreated: Date
}

extension CompositionHistoryEvent {
    init(from compositionHistoryBlueprintResponse: Requests.CompositionHistoryGet.Response.Blueprint) {
        self.init(
            blueprintId: compositionHistoryBlueprintResponse.id,
            creator: .init(from: compositionHistoryBlueprintResponse.creator),
            timeCreated: Date() // TODO: Поддержать на беке
        )
    }
}
