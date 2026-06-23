import SwiftUI

struct ServerFormView: View {
    let serverType: ServerType
    let existing: HTTPServerConfig?
    let onSave: (HTTPServerConfig) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: HTTPServerConfig

    init(serverType: ServerType, existing: HTTPServerConfig?, onSave: @escaping (HTTPServerConfig) -> Void) {
        self.serverType = serverType
        self.existing = existing
        self.onSave = onSave
        _draft = State(initialValue: existing ?? .empty(type: serverType))
    }

    private var isEditing: Bool { existing != nil }

    private var domainsValid: Bool {
        !draft.domains.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var targetValid: Bool {
        draft.isProxy
            ? !draft.proxyTarget.trimmingCharacters(in: .whitespaces).isEmpty
            : !draft.path.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var sslValid: Bool {
        guard draft.https, draft.ssl == .custom else { return true }
        return !draft.sslCustomCert.isEmpty && !draft.sslCustomKey.isEmpty
    }

    private var canSave: Bool { domainsValid && targetValid && sslValid }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                Form {
                    domainsSection
                    portsSection
                    modeSection
                    if draft.https { sslSection }
                }
                .formStyle(.grouped)
                .padding(.vertical, 4)
            }
        }
        .frame(width: 500)
        .fixedSize(horizontal: true, vertical: false)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: serverType.systemImage)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(isEditing ? "Edit \(serverType.displayName) Server" : "New \(serverType.displayName) Server")
                    .font(.headline)
                if isEditing, !draft.primaryDomain.isEmpty {
                    Text(draft.primaryDomain)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button("Cancel") { dismiss() }
                .keyboardShortcut(.escape)

            Button(isEditing ? "Save Changes" : "Add Server") {
                onSave(draft)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canSave)
            .keyboardShortcut(.return, modifiers: .command)
        }
        .padding()
    }

    // MARK: - Sections

    private var domainsSection: some View {
        Section {
            TextField("example.com, www.example.com", text: $draft.domains)
        } header: {
            Text("Domains")
        } footer: {
            if !domainsValid && !draft.domains.isEmpty {
                Text("At least one domain is required.")
                    .foregroundStyle(.red)
            } else {
                Text("Separate multiple domains with commas. The first one becomes the primary.")
            }
        }
    }

    private var portsSection: some View {
        Section("Ports") {
            Toggle("HTTP  (port 80)", isOn: $draft.http)
            Toggle("HTTPS (port 443)", isOn: $draft.https)
            if draft.https && draft.http {
                Toggle("Redirect HTTP → HTTPS", isOn: $draft.redirect)
            }
        }
    }

    private var modeSection: some View {
        Section {
            Toggle("Reverse Proxy", isOn: $draft.isProxy.animation())

            if draft.isProxy {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(.orange)
                        .frame(width: 20)
                    TextField("127.0.0.1:3000", text: $draft.proxyTarget)
                }
            } else {
                HStack {
                    Image(systemName: "folder")
                        .foregroundStyle(.secondary)
                        .frame(width: 20)
                    TextField("/var/www/html", text: $draft.path)
                }
            }
        } header: {
            Text("Mode")
        } footer: {
            if draft.isProxy {
                Text("Traffic will be forwarded to the specified address.")
            } else {
                Text("The directory served as document root.")
            }
        }
    }

    private var sslSection: some View {
        Section("SSL Certificate") {
            Picker("Type", selection: $draft.ssl.animation()) {
                ForEach(SSLMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.radioGroup)

            if draft.ssl == .custom {
                Divider()
                HStack {
                    Text("Certificate").frame(width: 90, alignment: .trailing)
                    TextField("/etc/ssl/certs/example.pem", text: $draft.sslCustomCert)
                }
                HStack {
                    Text("Key").frame(width: 90, alignment: .trailing)
                    TextField("/etc/ssl/private/example.key", text: $draft.sslCustomKey)
                }
            }
        }
    }
}
