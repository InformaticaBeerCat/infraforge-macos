import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selection: SidebarItem?

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var totalConfigs: Int {
        dataStore.apacheServers.count + dataStore.nginxServers.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                featuresSection
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .leading) {
            heroBackground
            HStack(alignment: .center, spacing: 24) {
                heroIcon
                heroText
                Spacer()
                heroDivider
                heroStats
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 30)
        }
        .frame(maxWidth: .infinity)
    }

    private var heroBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.06, blue: 0.20), Color(red: 0.16, green: 0.05, blue: 0.28)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            GeometryReader { geo in
                Circle()
                    .fill(Color(red: 0.38, green: 0.18, blue: 0.72).opacity(0.28))
                    .frame(width: 220)
                    .blur(radius: 60)
                    .offset(x: geo.size.width - 130, y: -30)
                Circle()
                    .fill(Color(red: 0.22, green: 0.34, blue: 0.90).opacity(0.22))
                    .frame(width: 160)
                    .blur(radius: 50)
                    .offset(x: geo.size.width - 50, y: 60)
            }
        }
    }

    private var heroIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.44, green: 0.44, blue: 0.98), Color(red: 0.58, green: 0.18, blue: 0.88)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 72, height: 72)
                .shadow(color: .purple.opacity(0.55), radius: 14, y: 5)
            Image(systemName: "hammer.fill")
                .font(.system(size: 31, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var heroText: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Infraforge")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Generate production-ready server and database configurations\nfor Apache, Nginx, MySQL, PostgreSQL and more.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.60))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var heroDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.15))
            .frame(width: 1, height: 42)
    }

    private var heroStats: some View {
        HStack(spacing: 28) {
            HeroStat(value: totalConfigs, label: "Configs")
            HeroStat(value: 5, label: "Features")
        }
        .padding(.trailing, 4)
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                Text("Features")
                    .font(.title3.weight(.bold))
                Text("·")
                    .foregroundStyle(.tertiary)
                Text("2 available · 3 coming soon")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 28)
            .padding(.top, 28)

            LazyVGrid(columns: columns, spacing: 14) {
                FeatureCard(
                    icon: ServerType.apache.systemImage,
                    gradient: ServerType.apache.iconGradient,
                    accentColor: ServerType.apache.accentColor,
                    title: "Apache",
                    subtitle: "HTTP Server",
                    description: "Virtual host configs with SSL, HTTP/HTTPS redirects, custom document root and reverse proxy.",
                    badge: badgeLabel(dataStore.apacheServers.count),
                    isAvailable: true,
                    action: { selection = .httpServers(.apache) }
                )

                FeatureCard(
                    icon: ServerType.nginx.systemImage,
                    gradient: ServerType.nginx.iconGradient,
                    accentColor: ServerType.nginx.accentColor,
                    title: "Nginx",
                    subtitle: "HTTP Server",
                    description: "Server block configs with SSL, upstream proxy, static file serving and Let's Encrypt support.",
                    badge: badgeLabel(dataStore.nginxServers.count),
                    isAvailable: true,
                    action: { selection = .httpServers(.nginx) }
                )

                FeatureCard(
                    icon: "cylinder.split.1x2.fill",
                    gradient: LinearGradient(
                        colors: [Color(red: 0.0, green: 0.54, blue: 0.88), Color(red: 0.0, green: 0.34, blue: 0.70)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    accentColor: Color(red: 0.0, green: 0.54, blue: 0.88),
                    title: "MySQL",
                    subtitle: "Database",
                    description: "Create databases, user accounts and privilege setup scripts ready for deployment.",
                    badge: nil,
                    isAvailable: false
                )

                FeatureCard(
                    icon: "externaldrive.fill.badge.plus",
                    gradient: LinearGradient(
                        colors: [Color(red: 0.25, green: 0.44, blue: 0.80), Color(red: 0.12, green: 0.26, blue: 0.60)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    accentColor: Color(red: 0.25, green: 0.44, blue: 0.80),
                    title: "PostgreSQL",
                    subtitle: "Database",
                    description: "Role, database and schema setup scripts with charset, privileges and host configuration.",
                    badge: nil,
                    isAvailable: false
                )

                FeatureCard(
                    icon: "key.fill",
                    gradient: LinearGradient(
                        colors: [Color(red: 0.62, green: 0.20, blue: 0.84), Color(red: 0.40, green: 0.08, blue: 0.64)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    accentColor: Color(red: 0.62, green: 0.20, blue: 0.84),
                    title: "Flask Secret Keys",
                    subtitle: "Security",
                    description: "Generate, store and manage secret keys for Flask applications with descriptions.",
                    badge: nil,
                    isAvailable: false
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func badgeLabel(_ count: Int) -> String? {
        guard count > 0 else { return nil }
        return count == 1 ? "1 config" : "\(count) configs"
    }
}

// MARK: - Hero Stat

private struct HeroStat: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 3) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.50))
        }
    }
}

// MARK: - Feature Card

struct FeatureCard: View {
    let icon: String
    let gradient: LinearGradient
    let accentColor: Color
    let title: String
    let subtitle: String
    let description: String
    let badge: String?
    let isAvailable: Bool
    var action: () -> Void = {}

    @State private var isHovered = false

    var body: some View {
        Button(action: isAvailable ? action : {}) {
            VStack(alignment: .leading, spacing: 0) {
                cardTop
                cardBody
                Spacer(minLength: 14)
                Divider().padding(.horizontal, 16)
                cardBottom
            }
            .frame(maxWidth: .infinity, minHeight: 188, alignment: .topLeading)
            .background(cardBackground)
            .overlay(cardBorder)
            .scaleEffect(isHovered && isAvailable ? 1.018 : 1.0)
        }
        .buttonStyle(.plain)
        .opacity(isAvailable ? 1.0 : 0.60)
        .onHover { isHovered = $0 }
        .animation(.spring(duration: 0.20), value: isHovered)
        .disabled(!isAvailable)
    }

    // Top: icon + badge
    private var cardTop: some View {
        HStack(alignment: .top) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(gradient)
                    .frame(width: 48, height: 48)
                    .shadow(
                        color: accentColor.opacity(isAvailable ? (isHovered ? 0.50 : 0.30) : 0.15),
                        radius: isHovered ? 8 : 5, y: 2
                    )
                Image(systemName: icon)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Spacer()
            if let badge {
                Text(badge)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(accentColor.opacity(0.12), in: Capsule())
            } else if !isAvailable {
                Label("Coming soon", systemImage: "clock")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.08), in: Capsule())
            }
        }
        .padding(16)
    }

    // Body: title + description
    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(isAvailable ? .primary : .secondary)
                Text(subtitle.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 3))
            }
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
    }

    // Bottom: action label
    private var cardBottom: some View {
        HStack {
            if isAvailable {
                Label("Open", systemImage: "arrow.right.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isHovered ? accentColor : accentColor.opacity(0.70))
            } else {
                Label("Not yet available", systemImage: "xmark.circle")
                    .font(.caption)
                    .foregroundStyle(.quaternary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 13)
            .fill(Color(NSColor.controlBackgroundColor))
            .shadow(
                color: .black.opacity(isHovered && isAvailable ? 0.10 : 0.04),
                radius: isHovered ? 10 : 3,
                y: isHovered ? 4 : 1
            )
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 13)
            .strokeBorder(
                isHovered && isAvailable ? accentColor.opacity(0.28) : Color.primary.opacity(0.07),
                lineWidth: 1
            )
    }
}
