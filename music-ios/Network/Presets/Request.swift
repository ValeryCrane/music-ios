import Foundation

protocol Request {
    associatedtype Parameters
    associatedtype Response
    
    func run(with parameters: Parameters) async throws -> Response
}

enum Requests {}
