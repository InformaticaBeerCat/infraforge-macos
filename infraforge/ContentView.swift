import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selection: SidebarItem? = .home

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
                .environmentObject(dataStore)
        } detail: {
            detailView
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .home:
            HomeView(selection: $selection)
                .environmentObject(dataStore)
        case .httpServers(let type):
            ServerListView(serverType: type)
        case nil:
            ContentUnavailableView(
                "Select a Section",
                systemImage: "sidebar.left",
                description: Text("Choose a category from the sidebar.")
            )
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataStore.shared)
}
