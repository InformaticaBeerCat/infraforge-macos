import Foundation
import SwiftUI

enum ServerType: String, Codable, CaseIterable, Hashable {
    case apache
    case nginx

    var displayName: String {
        switch self {
        case .apache: "Apache"
        case .nginx: "Nginx"
        }
    }

    var systemImage: String {
        switch self {
        case .apache: "server.rack"
        case .nginx: "bolt.horizontal.circle"
        }
    }

    var accentColor: Color {
        switch self {
        case .apache: Color(red: 0.85, green: 0.28, blue: 0.02)
        case .nginx: Color(red: 0.0, green: 0.58, blue: 0.22)
        }
    }

    var iconGradient: LinearGradient {
        switch self {
        case .apache:
            LinearGradient(
                colors: [Color(red: 0.95, green: 0.42, blue: 0.1), Color(red: 0.72, green: 0.14, blue: 0.0)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .nginx:
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.78, blue: 0.35), Color(red: 0.0, green: 0.50, blue: 0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
}

enum SSLMode: String, Codable, CaseIterable, Hashable {
    case certbot
    case snakeoil
    case custom

    var displayName: String {
        switch self {
        case .certbot: "Certbot (Let's Encrypt)"
        case .snakeoil: "Snakeoil (Self-signed)"
        case .custom: "Custom Certificate"
        }
    }

    var shortName: String {
        switch self {
        case .certbot: "Certbot"
        case .snakeoil: "Snakeoil"
        case .custom: "Custom"
        }
    }
}

struct HTTPServerConfig: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var serverType: ServerType
    var domains: String = ""
    var http: Bool = true
    var https: Bool = false
    var path: String = "/var/www/html"
    var ssl: SSLMode = .certbot
    var sslCustomCert: String = ""
    var sslCustomKey: String = ""
    var redirect: Bool = false
    var isProxy: Bool = false
    var proxyTarget: String = ""

    var primaryDomain: String {
        domainList.first ?? domains.trimmingCharacters(in: .whitespaces)
    }

    var domainList: [String] {
        domains
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var portsLabel: String {
        var ports: [String] = []
        if http { ports.append("80") }
        if https { ports.append("443") }
        return ports.joined(separator: ", ")
    }

    static func empty(type: ServerType) -> HTTPServerConfig {
        HTTPServerConfig(serverType: type)
    }
}
