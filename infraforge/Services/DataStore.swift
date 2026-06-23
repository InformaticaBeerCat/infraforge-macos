import Foundation
import Combine

class DataStore: ObservableObject {
    static let shared = DataStore()

    @Published var apacheServers: [HTTPServerConfig] = []
    @Published var nginxServers: [HTTPServerConfig] = []
    @Published var settings: AppSettings = .default

    private let appSupportURL: URL

    private init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        appSupportURL = base.appendingPathComponent("infraforge")
        try? FileManager.default.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
        loadAll()
    }

    // MARK: - Persistence

    private func loadAll() {
        settings = load("settings.json") ?? .default
        apacheServers = load("apache_servers.json") ?? []
        nginxServers = load("nginx_servers.json") ?? []
    }

    private func load<T: Decodable>(_ filename: String) -> T? {
        let url = appSupportURL.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func save<T: Encodable>(_ value: T, as filename: String) {
        let url = appSupportURL.appendingPathComponent(filename)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(value) else { return }
        try? data.write(to: url, options: .atomicWrite)
    }

    func saveSettings() {
        save(settings, as: "settings.json")
    }

    // MARK: - Server CRUD

    func servers(for type: ServerType) -> [HTTPServerConfig] {
        type == .apache ? apacheServers : nginxServers
    }

    func add(_ config: HTTPServerConfig) {
        switch config.serverType {
        case .apache:
            apacheServers.append(config)
            save(apacheServers, as: "apache_servers.json")
        case .nginx:
            nginxServers.append(config)
            save(nginxServers, as: "nginx_servers.json")
        }
    }

    func update(_ config: HTTPServerConfig) {
        switch config.serverType {
        case .apache:
            guard let i = apacheServers.firstIndex(where: { $0.id == config.id }) else { return }
            apacheServers[i] = config
            save(apacheServers, as: "apache_servers.json")
        case .nginx:
            guard let i = nginxServers.firstIndex(where: { $0.id == config.id }) else { return }
            nginxServers[i] = config
            save(nginxServers, as: "nginx_servers.json")
        }
    }

    func delete(_ config: HTTPServerConfig) {
        switch config.serverType {
        case .apache:
            apacheServers.removeAll { $0.id == config.id }
            save(apacheServers, as: "apache_servers.json")
        case .nginx:
            nginxServers.removeAll { $0.id == config.id }
            save(nginxServers, as: "nginx_servers.json")
        }
    }
}
