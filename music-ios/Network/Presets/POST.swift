import Foundation

struct POST<Parameters: Encodable, Response: Decodable>: NetworkRequest {
    
    private let path: String
    
    init(path: String) {
        self.path = path
    }
    
    func serialize(with parameters: Parameters, environment: NetworkEnvironment) throws -> NetworkRequestDescription {
        let data = try JSONEncoder().encode(parameters)
        
        return .init(
            method: "POST",
            scheme: environment.scheme,
            host: environment.host,
            port: environment.port,
            path: path,
            urlParameters: [:],
            headers: environment.commonHeaders,
            body: data
        )
    }
    
    func deserialize(from data: Data) throws -> Response {
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw NetworkError.deserializationError(message: "Couln't deserialize response")
        }
    }
}
