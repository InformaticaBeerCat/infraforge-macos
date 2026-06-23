import Foundation
import AppKit

enum FileServiceError: LocalizedError {
    case fileExists(URL)
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .fileExists(let url): "File already exists at \(url.lastPathComponent)"
        case .generationFailed(let reason): "Generation failed: \(reason)"
        }
    }
}

struct FileService {

    static func configDirURL(for config: HTTPServerConfig, workdir: String) -> URL {
        URL(fileURLWithPath: workdir)
            .appendingPathComponent("http-configs")
            .appendingPathComponent(config.serverType.rawValue)
            .appendingPathComponent(config.primaryDomain)
    }

    static func configFileURL(for config: HTTPServerConfig, workdir: String) -> URL {
        configDirURL(for: config, workdir: workdir)
            .appendingPathComponent("\(config.primaryDomain).conf")
    }

    static func configFileExists(for config: HTTPServerConfig, workdir: String) -> Bool {
        FileManager.default.fileExists(atPath: configFileURL(for: config, workdir: workdir).path)
    }

    @discardableResult
    static func generateAndSave(
        _ config: HTTPServerConfig,
        workdir: String,
        overwrite: Bool = false
    ) throws -> URL {
        let dirURL = configDirURL(for: config, workdir: workdir)
        let fileURL = configFileURL(for: config, workdir: workdir)

        try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)

        if FileManager.default.fileExists(atPath: fileURL.path) && !overwrite {
            throw FileServiceError.fileExists(fileURL)
        }

        let content = ConfigGenerator.generate(config)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    static func openInFinder(_ url: URL) {
        NSWorkspace.shared.open(url)
    }

    static func revealInFinder(_ fileURL: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
    }
}
