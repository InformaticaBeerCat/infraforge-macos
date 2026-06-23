import SwiftUI
import AppKit

struct SettingsView: View {
    @EnvironmentObject var dataStore: DataStore

    var body: some View {
        Form {
            Section {
                HStack(spacing: 8) {
                    TextField("Working directory", text: $dataStore.settings.workdir)
                        .onChange(of: dataStore.settings.workdir) {
                            dataStore.saveSettings()
                        }

                    Button {
                        selectFolder()
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                    .help("Choose a folder")

                    Button {
                        FileService.openInFinder(
                            URL(fileURLWithPath: dataStore.settings.workdir)
                        )
                    } label: {
                        Image(systemName: "arrow.up.forward.app")
                    }
                    .help("Open in Finder")
                    .disabled(!FileManager.default.fileExists(atPath: dataStore.settings.workdir))
                }
            } header: {
                Text("Generated Files")
            } footer: {
                Text("All generated configs and scripts will be saved under this directory.")
            }

            Section("Data") {
                LabeledContent("Configuration database") {
                    Text(appSupportPath)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 480)
        .fixedSize()
    }

    private var appSupportPath: String {
        (FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("infraforge").path) ?? "~"
    }

    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "Select"
        panel.message = "Choose the folder where generated files will be saved"

        guard panel.runModal() == .OK, let url = panel.url else { return }
        dataStore.settings.workdir = url.path
        dataStore.saveSettings()
    }
}
