import SwiftUI

enum SidebarItem: Hashable {
    case home
    case httpServers(ServerType)
}

struct SidebarView: View {
    @Binding var selection: SidebarItem?
    @EnvironmentObject var dataStore: DataStore

    var body: some View {
        List(selection: $selection) {
            appBrand
                .listRowInsets(EdgeInsets(top: 12, leading: 14, bottom: 10, trailing: 14))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .selectionDisabled()

            Section {
                SidebarRow(
                    icon: "square.grid.2x2.fill",
                    label: "Overview",
                    gradient: LinearGradient(
                        colors: [Color(red: 0.38, green: 0.38, blue: 0.95), Color(red: 0.55, green: 0.18, blue: 0.82)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    accentColor: .purple,
                    count: nil,
                    isSelected: selection == .home
                )
                .tag(SidebarItem.home)
            }

            Section {
                ForEach(ServerType.allCases, id: \.self) { type in
                    SidebarRow(
                        icon: type.systemImage,
                        label: type.displayName,
                        gradient: type.iconGradient,
                        accentColor: type.accentColor,
                        count: dataStore.servers(for: type).count,
                        isSelected: selection == .httpServers(type)
                    )
                    .tag(SidebarItem.httpServers(type))
                }
            } header: {
                Text("HTTP Servers")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 2)
            }
        }
        .listStyle(.sidebar)
    }

    // MARK: - App brand

    private var appBrand: some View {
        HStack(spacing: 11) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.38, green: 0.38, blue: 0.95), Color(red: 0.55, green: 0.18, blue: 0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 38)
                    .shadow(color: .purple.opacity(0.35), radius: 5, y: 2)
                Image(systemName: "hammer.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("Infraforge")
                    .font(.system(size: 14, weight: .bold))
                Text("Config Generator")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Sidebar Row

struct SidebarRow: View {
    let icon: String
    let label: String
    let gradient: LinearGradient
    let accentColor: Color
    let count: Int?
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            rowIcon
            Text(label)
                .fontWeight(.medium)
            Spacer()
            if let n = count, n > 0 {
                countBadge(n)
            }
        }
        .padding(.vertical, 3)
        .contentShape(Rectangle())
    }

    private var rowIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(gradient)
                .frame(width: 28, height: 28)
                .shadow(color: accentColor.opacity(0.28), radius: 3, y: 1)
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private func countBadge(_ n: Int) -> some View {
        Text("\(n)")
            .font(.caption2.weight(.bold))
            .monospacedDigit()
            .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                isSelected
                    ? Color.white.opacity(0.20)
                    : Color.secondary.opacity(0.12),
                in: Capsule()
            )
    }
}
