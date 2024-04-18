import Foundation

enum SearchGroup: String, CaseIterable, Identifiable {
    var id: Self { return self }
    
    case compositions = "Композиции"
    case users = "Пользователи"
}
