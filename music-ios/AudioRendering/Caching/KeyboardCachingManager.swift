import Foundation

extension KeyboardCachingManager {
    private enum Constants {
        static let keyboardsSubpath = "keyboards/"
    }
}

final class KeyboardCachingManager {
    
    typealias Keyboard = (id: Int, name: String, keys: [URL])

    private struct KeyboardInfo: Codable {
        let name: String
        let keySampleIds: [Int]
    }
    
    private let keyboardGet = Requests.KeyboardGet()
    
    private let sampleCachingManager = SampleCachingManager()
    
    func loadKeyboard(id: Int) async throws -> Keyboard {
        guard var cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw CachingError.cacheDirectoryNotFound
        }
        
        cachesDirectoryURL.append(path: Constants.keyboardsSubpath)
        try FileManager.default.createDirectory(at: cachesDirectoryURL, withIntermediateDirectories: true)
        cachesDirectoryURL.append(path: "\(id).json")
        
        if !FileManager.default.fileExists(atPath: cachesDirectoryURL.path()) {
            let keyboardResponse = try await keyboardGet.run(with: .init(id: id))
            let samples = try await loadSamples(ids: keyboardResponse.keySampleIds)
            let keyboardInfo = KeyboardInfo(name: keyboardResponse.name, keySampleIds: keyboardResponse.keySampleIds)
            try JSONEncoder().encode(keyboardInfo).write(to: cachesDirectoryURL)
            return (id: id, name: keyboardResponse.name, keys: samples)
        } else if let keyboardData = FileManager.default.contents(atPath: cachesDirectoryURL.path()) {
            let keyboardInfo = try JSONDecoder().decode(KeyboardInfo.self, from: keyboardData)
            let samples = try await loadSamples(ids: keyboardInfo.keySampleIds)
            return (id: id, name: keyboardInfo.name, keys: samples)
        } else {
            throw CachingError.corruptedKeyboardFile
        }
    }
    
    private func loadSamples(ids: [Int]) async throws -> [URL] {
        try await withThrowingTaskGroup(of: (Int, URL).self) { group in
            var keyMap = [Int: URL]()

            ids.enumerated().forEach { (index, sampleId) in
                group.addTask { [weak self] in
                    if let self = self {
                        return (index, try await self.sampleCachingManager.loadSample(id: sampleId))
                    } else {
                        throw CancellationError()
                    }
                }
            }

            for try await urlInfo in group {
                keyMap[urlInfo.0] = urlInfo.1
            }
            
            return (0 ..< ids.count).compactMap { keyMap[$0] }
        }
    }
}
