import Foundation

enum NetworkError: Error {
    case serializationError(message: String)
    case deserializationError(message: String)
}
