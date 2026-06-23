import SwiftUI

@main
struct infraforgeApp: App {
    @StateObject private var dataStore = DataStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 960, height: 620)

        Settings {
            SettingsView()
                .environmentObject(dataStore)
        }
    }
}
