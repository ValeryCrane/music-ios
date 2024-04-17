import Foundation
import UIKit

struct MultipartFormdataParameter {
    let key: String
    let value: Data
    let filename: String?
    let contentType: String?

    private init(key: String, value: Data, filename: String?, contentType: String?) {
        self.key = key
        self.value = value
        self.filename = filename
        self.contentType = contentType
    }

    static func imageJPEG(_ image: UIImage, key: String, filename: String) -> Self? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        
        return .init(
            key: key,
            value: imageData,
            filename: filename,
            contentType: "image/jpeg"
        )
    }
}

struct MultipartFormdataPOST<Response: Decodable>: NetworkRequest {
    static var boundary: String { "--------mkAoPcxhYzPaYgNV" }
    
    typealias Parameters = [MultipartFormdataParameter]
    
    private let path: String
    
    init(path: String) {
        self.path = path
    }
    
    func serialize(with parameters: Parameters, environment: NetworkEnvironment) throws -> NetworkRequestDescription {
        var headers = environment.commonHeaders
        headers["Content-Type"] = "multipart/form-data; boundary=\(Self.boundary)"
        
        return .init(
            method: "POST",
            scheme: environment.scheme,
            host: environment.host,
            port: environment.port,
            path: path,
            urlParameters: [:],
            headers: headers,
            body: createBodyFromParameters(parameters)
        )
    }
    
    func deserialize(from data: Data) throws -> Response {
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw NetworkError.deserializationError(message: "Couln't deserialize response")
        }
    }
    
    private func createBodyFromParameters(_ parameters: Parameters) -> Data {
        var data = Data()
        data.append("\r\n--\(Self.boundary)\r\n".data(using: .utf8)!)
        
        for parameter in parameters {
            data.append("Content-Disposition: form-data; name=\"\(parameter.key)\"".data(using: .utf8)!)
            if let filename = parameter.filename {
                data.append("; filename=\"\(filename)\"".data(using: .utf8)!)
            }
            data.append("\r\n".data(using: .utf8)!)
            if let contentType = parameter.contentType {
                data.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
            }
            data.append(parameter.value)
            
            data.append("\r\n--\(Self.boundary)--\r\n".data(using: .utf8)!)
        }
        
        return data
    }
}
