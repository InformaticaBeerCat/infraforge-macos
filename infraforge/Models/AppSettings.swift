import Foundation

struct AppSettings: Codable {
    var workdir: String

    static var defaultWorkdir: String {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("infraforge")
            .path
    }

    static var `default`: AppSettings {
        AppSettings(workdir: defaultWorkdir)
    }
}
