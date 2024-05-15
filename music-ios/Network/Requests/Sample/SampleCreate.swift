import Foundation
import UIKit

extension Requests {
    struct SampleCreate: Request {
        struct Parameters: Encodable {
            let sampleURL: URL
            let name: String
            let beats: Int
        }

        struct Response: Decodable {
            let id: Int
        }

        private let request = MultipartFormdataPOST<Response>(path: "/sample")

        @discardableResult
        func run(with parameters: Parameters) async throws -> Response {
            guard 
                let audioParameter = MultipartFormdataParameter.audioWAV(parameters.sampleURL, key: "file", filename: "audio.wav"),
                let nameParameter = MultipartFormdataParameter.text(parameters.name, key: "name"),
                let beatsParameter = MultipartFormdataParameter.text("\(parameters.beats)", key: "beats")
            else { throw RuntimeError("Ошибка сериализации аудио-данных сэмпла") }

            return try await request.run(with: [audioParameter, nameParameter, beatsParameter], environment: NetworkEnvironments.default)
        }
    }
}
