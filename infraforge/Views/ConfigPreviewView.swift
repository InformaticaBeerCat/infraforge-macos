import SwiftUI
import AppKit

struct ConfigPreviewView: View {
    let config: HTTPServerConfig
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataStore: DataStore

    @State private var copied = false

    private var generatedText: String {
        ConfigGenerator.generate(config)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            codeBlock
        }
        .frame(width: 620, height: 480)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: config.serverType.systemImage)
                .font(.title3)
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 1) {
                Text("\(config.serverType.displayName) — \(config.primaryDomain)")
                    .font(.headline)
                Text(config.portsLabel.isEmpty ? "No ports enabled" : "Ports: \(config.portsLabel)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(generatedText, forType: .string)
                copied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
            } label: {
                Label(copied ? "Copied!" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
            }
            .animation(.easeInOut(duration: 0.2), value: copied)

            Button("Done") { dismiss() }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: .command)
        }
        .padding()
    }

    private var codeBlock: some View {
        ScrollView([.horizontal, .vertical]) {
            Text(generatedText)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Color(NSColor.textBackgroundColor))
    }
}
