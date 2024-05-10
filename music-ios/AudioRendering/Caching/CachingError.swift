import Foundation

enum CachingError: Error {
    case cacheDirectoryNotFound
    case corruptedKeyboardFile
}
