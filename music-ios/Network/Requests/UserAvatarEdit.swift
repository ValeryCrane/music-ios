import Foundation
import UIKit

enum UserAvatarEditError: Error {
    case incorrectImageFormat
}

extension Requests {
    struct UserAvatarEdit: Request {
        typealias Parameters = UIImage
        
        struct Response: Decodable {
            let success: Bool
        }
        
        private let request = MultipartFormdataPOST<Response>(path: "/user/avatar")
        
        @discardableResult
        func run(with parameters: Parameters) async throws -> Response {
            guard let imageParameter = MultipartFormdataParameter.imageJPEG(
                parameters, key: "file", filename: "avatar.jpeg"
            ) else { throw UserAvatarEditError.incorrectImageFormat }
            
            return try await request.run(with: [imageParameter], environment: NetworkEnvironments.default)
        }
    }
}
