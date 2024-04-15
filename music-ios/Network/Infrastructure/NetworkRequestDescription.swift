import Foundation

struct NetworkRequestDescription {
    let method: String
    
    let scheme: String
    let host: String
    let port: Int
    
    let path: String
    let urlParameters: [String: String]
    
    let headers: [String: String]
    
    let body: Data?
}
