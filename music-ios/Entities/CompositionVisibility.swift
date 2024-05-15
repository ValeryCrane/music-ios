import Foundation

enum CompositionVisibility: String, Codable {
    case `private`
    case `public`

    var other: CompositionVisibility {
        switch self {
        case .private:
            .public
        case .public:
            .private
        }
    }
}
