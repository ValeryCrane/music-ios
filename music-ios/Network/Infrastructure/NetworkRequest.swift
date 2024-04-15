import Foundation

protocol NetworkRequest {
    associatedtype Parameters
    associatedtype Response
    
    func run(with parameters: Parameters, environment: NetworkEnvironment) async throws -> Response
    func serialize(with parameters: Parameters, environment: NetworkEnvironment) throws -> NetworkRequestDescription
    func deserialize(from data: Data) throws -> Response
}

extension NetworkRequest {
    func run(with parameters: Parameters, environment: NetworkEnvironment) async throws -> Response {
        let requestDescription = try serialize(with: parameters, environment: environment)
        let networkModel = NetworkModel()
        let responseData = try await networkModel.runRequest(with: requestDescription)
        return try deserialize(from: responseData)
    }
}
