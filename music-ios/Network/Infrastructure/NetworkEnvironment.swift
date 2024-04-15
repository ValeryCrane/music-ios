import Foundation

struct NetworkEnvironment {
    let scheme: String
    let host: String
    let port: Int
    let commonHeaders: [String: String]
}
