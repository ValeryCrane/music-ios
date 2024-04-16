import Foundation

struct PATCH<Parameters: Encodable, Response: Decodable>: NetworkRequest {
    
    private let path: String
    
    init(path: String) {
        self.path = path
    }
    
    func serialize(with parameters: Parameters, environment: NetworkEnvironment) throws -> NetworkRequestDescription {
        let data = try JSONEncoder().encode(parameters)
        var headers = environment.commonHeaders
        headers["Content-Type"] = "application/json"
        
        return .init(
            method: "PATCH",
            scheme: environment.scheme,
            host: environment.host,
            port: environment.port,
            path: path,
            urlParameters: [:],
            headers: headers,
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
