import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DownloadView()
                .tabItem {
                    Label("Download", systemImage: "arrow.down.circle.fill")
                }

            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "folder.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.red)
    }
}
