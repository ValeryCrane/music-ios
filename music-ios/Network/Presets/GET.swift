import Foundation

struct GET<Parameters: Encodable, Response: Decodable>: NetworkRequest {
    
    private let path: String
    
    init(path: String) {
        self.path = path
    }
    
    func serialize(with parameters: Parameters, environment: NetworkEnvironment) throws -> NetworkRequestDescription {
        let urlParameters = try createDictionary(from: parameters)
        
        return .init(
            method: "GET",
            scheme: environment.scheme,
            host: environment.host,
            port: environment.port,
            path: path,
            urlParameters: urlParameters.mapValues({ "\($0)" }),
            headers: environment.commonHeaders,
            body: nil
        )
    }
    
    func deserialize(from data: Data) throws -> Response {
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw NetworkError.deserializationError(message: "Couln't deserialize response")
        }
    }
    
    private func createDictionary(from encodable: Encodable) throws -> [String: Any] {
        do {
            let jsonData = try JSONEncoder().encode(encodable)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            if let dictionary = json as? [String: Any] {
                return dictionary
            } else {
                throw NetworkError.serializationError(message: "")
            }
        } catch {
            throw NetworkError.serializationError(message: "Couldn't serialize query items")
        }
    }
}
