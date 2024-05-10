import Foundation

extension SampleCachingManager {
    private enum Constants {
        static let samplesSubpath = "samples/"
    }
}

final class SampleCachingManager {
    
    private let sampleGet = Requests.SampleGet()
    
    func loadSample(id: Int) async throws -> URL {
        guard var cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw CachingError.cacheDirectoryNotFound
        }
        
        cachesDirectoryURL.append(path: Constants.samplesSubpath)
        try FileManager.default.createDirectory(at: cachesDirectoryURL, withIntermediateDirectories: true)
        cachesDirectoryURL.append(path: "\(id).wav")
        
        if !FileManager.default.fileExists(atPath: cachesDirectoryURL.path()) {
            let sampleData = try await sampleGet.run(with: .init(id: id))
            try sampleData.write(to: cachesDirectoryURL)
        }
        
        return cachesDirectoryURL
    }
}
