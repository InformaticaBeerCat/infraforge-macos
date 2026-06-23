import SwiftUI

struct ServerListView: View {
    let serverType: ServerType
    @EnvironmentObject var dataStore: DataStore

    @State private var selectedID: UUID?
    @State private var showForm = false
    @State private var editingConfig: HTTPServerConfig?
    @State private var previewConfig: HTTPServerConfig?
    @State private var confirmDelete: HTTPServerConfig?
    @State private var confirmOverwrite: HTTPServerConfig?
    @State private var toastMessage: String?
    @State private var toastIsError = false

    private var servers: [HTTPServerConfig] {
        dataStore.servers(for: serverType)
    }

    private var selectedConfig: HTTPServerConfig? {
        guard let id = selectedID else { return nil }
        return servers.first { $0.id == id }
    }

    var body: some View {
        VStack(spacing: 0) {
            if servers.isEmpty {
                emptyState
            } else {
                statsBar
                Divider()
                serverTable
            }
        }
        .navigationTitle(serverType.displayName)
        .toolbar { toolbarItems }
        .sheet(isPresented: $showForm) {
            ServerFormView(
                serverType: serverType,
                existing: editingConfig
            ) { saved in
                if editingConfig != nil {
                    dataStore.update(saved)
                    toast("Server updated")
                } else {
                    dataStore.add(saved)
                    toast("Server added")
                }
            }
        }
        .sheet(item: $previewConfig) { config in
            ConfigPreviewView(config: config)
        }
        .alert("Delete Server", isPresented: Binding(
            get: { confirmDelete != nil },
            set: { if !$0 { confirmDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let c = confirmDelete {
                    dataStore.delete(c)
                    selectedID = nil
                    toast("Server deleted")
                }
                confirmDelete = nil
            }
            Button("Cancel", role: .cancel) { confirmDelete = nil }
        } message: {
            if let c = confirmDelete {
                Text("Delete \"\(c.primaryDomain)\"? This cannot be undone.")
            }
        }
        .alert("File Already Exists", isPresented: Binding(
            get: { confirmOverwrite != nil },
            set: { if !$0 { confirmOverwrite = nil } }
        )) {
            Button("Overwrite") {
                if let c = confirmOverwrite {
                    generateConfig(c, overwrite: true)
                }
                confirmOverwrite = nil
            }
            Button("Cancel", role: .cancel) { confirmOverwrite = nil }
        } message: {
            if let c = confirmOverwrite {
                Text("A config file already exists for \"\(c.primaryDomain)\". Overwrite it?")
            }
        }
        .overlay(alignment: .bottom) {
            if let msg = toastMessage {
                ToastView(message: msg, isError: toastIsError)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.25), value: toastMessage)
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack(spacing: 10) {
            StatChip(
                label: servers.count == 1 ? "1 server" : "\(servers.count) servers",
                icon: serverType.systemImage,
                color: serverType.accentColor
            )
            StatChip(
                label: "\(servers.filter { $0.http }.count) HTTP",
                icon: "globe",
                color: .blue
            )
            StatChip(
                label: "\(servers.filter { $0.https }.count) HTTPS",
                icon: "lock.fill",
                color: .green
            )
            if servers.filter({ $0.isProxy }).count > 0 {
                StatChip(
                    label: "\(servers.filter { $0.isProxy }.count) Proxy",
                    icon: "arrow.triangle.2.circlepath",
                    color: .orange
                )
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 9)
        .background(.bar)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(serverType.accentColor.opacity(0.10))
                    .frame(width: 88, height: 88)
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(serverType.accentColor.opacity(0.22), lineWidth: 1)
                    .frame(width: 88, height: 88)
                Image(systemName: serverType.systemImage)
                    .font(.system(size: 38, weight: .light))
                    .foregroundStyle(serverType.accentColor.opacity(0.75))
            }

            VStack(spacing: 6) {
                Text("No \(serverType.displayName) servers yet")
                    .font(.title3.weight(.semibold))
                Text("Add a server to generate virtual host configurations.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                editingConfig = nil
                showForm = true
            } label: {
                Label("Add \(serverType.displayName) Server", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .tint(serverType.accentColor)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Table

    private var serverTable: some View {
        Table(servers, selection: $selectedID) {
            TableColumn("Domains") { config in
                VStack(alignment: .leading, spacing: 2) {
                    Text(config.primaryDomain)
                        .fontWeight(.medium)
                    if config.domainList.count > 1 {
                        Text("+\(config.domainList.count - 1) more")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            TableColumn("Ports") { config in
                HStack(spacing: 4) {
                    if config.http  { PortBadge(port: "80",  color: .blue) }
                    if config.https { PortBadge(port: "443", color: .green) }
                }
            }
            .width(ideal: 90, max: 110)

            TableColumn("Mode") { config in
                Label(
                    config.isProxy ? "Proxy" : "Static",
                    systemImage: config.isProxy ? "arrow.triangle.2.circlepath" : "folder"
                )
                .foregroundStyle(config.isProxy ? .orange : .secondary)
                .font(.subheadline)
            }
            .width(ideal: 90, max: 110)

            TableColumn("SSL") { config in
                if config.https {
                    Text(config.ssl.shortName)
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    Text("—").foregroundStyle(.tertiary)
                }
            }
            .width(ideal: 100, max: 140)
        }
        .contextMenu(forSelectionType: UUID.self) { ids in
            if let id = ids.first, let config = servers.first(where: { $0.id == id }) {
                Button("Edit…") {
                    editingConfig = config
                    showForm = true
                }
                Button("Preview Config") {
                    previewConfig = config
                }
                Divider()
                Button("Generate File") {
                    generateConfig(config, overwrite: false)
                }
                Button("Reveal in Finder") {
                    let url = FileService.configDirURL(for: config, workdir: dataStore.settings.workdir)
                    FileService.openInFinder(url)
                }
                Divider()
                Button("Delete", role: .destructive) {
                    confirmDelete = config
                }
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                if let config = selectedConfig {
                    previewConfig = config
                }
            } label: {
                Label("Preview", systemImage: "doc.text.magnifyingglass")
            }
            .disabled(selectedConfig == nil)

            Button {
                if let config = selectedConfig {
                    generateConfig(config, overwrite: false)
                }
            } label: {
                Label("Generate", systemImage: "square.and.arrow.down")
            }
            .disabled(selectedConfig == nil)

            Button {
                if let config = selectedConfig {
                    editingConfig = config
                    showForm = true
                }
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .disabled(selectedConfig == nil)

            Button {
                editingConfig = nil
                showForm = true
            } label: {
                Label("Add Server", systemImage: "plus")
            }
        }
    }

    // MARK: - Helpers

    private func generateConfig(_ config: HTTPServerConfig, overwrite: Bool) {
        do {
            let url = try FileService.generateAndSave(config, workdir: dataStore.settings.workdir, overwrite: overwrite)
            toast("Saved to \(url.deletingLastPathComponent().lastPathComponent)/\(url.lastPathComponent)")
        } catch FileServiceError.fileExists {
            confirmOverwrite = config
        } catch {
            toast(error.localizedDescription, isError: true)
        }
    }

    private func toast(_ message: String, isError: Bool = false) {
        toastMessage = message
        toastIsError = isError
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if toastMessage == message {
                toastMessage = nil
            }
        }
    }
}

// MARK: - Sub-views

struct PortBadge: View {
    let port: String
    let color: Color

    var body: some View {
        Text(port)
            .font(.caption2.bold())
            .monospacedDigit()
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.13))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct StatChip: View {
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        Label(label, systemImage: icon)
            .font(.caption.weight(.medium))
            .foregroundStyle(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 7))
    }
}

struct ToastView: View {
    let message: String
    let isError: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isError ? "xmark.circle.fill" : "checkmark.circle.fill")
                .foregroundStyle(isError ? .red : .green)
            Text(message)
                .font(.subheadline)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 11))
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}
