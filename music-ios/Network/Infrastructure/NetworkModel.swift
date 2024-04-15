import Foundation

struct NetworkModel {
    
    func runRequest(with description: NetworkRequestDescription) async throws -> Data {
        let request = try createURLRequest(from: description)
        let (data, response) = try await URLSession.shared.data(for: request)
        return data
    }
    
    private func createURLRequest(from description: NetworkRequestDescription) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = description.scheme
        components.host = description.host
        components.port = description.port
        components.path = description.path
        components.queryItems = description.urlParameters.map({ .init(name: $0.key, value: $0.value) })
        
        guard let url = components.url else {
            throw NetworkError.serializationError(message: "Couldn't serialize URL")
        }
        
        var request = URLRequest(url: url)
        description.headers.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })
        request.httpBody = description.body
        
        return request
    }
}
