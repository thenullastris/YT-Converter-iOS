import SwiftUI

struct LibraryView: View {
    @StateObject private var vm = DownloadViewModel()
    @State private var shareURL: URL?
    @State private var showShare = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if vm.recentDownloads.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.gray.opacity(0.3))
                        Text("No downloads yet")
                            .foregroundStyle(.gray)
                    }
                } else {
                    List {
                        ForEach(vm.recentDownloads) { item in
                            RecentDownloadRow(item: item) {
                                let url = URL(fileURLWithPath: item.filePath)
                                shareURL = url
                                showShare = true
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.clear)
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showShare) {
            if let url = shareURL {
                ShareSheet(url: url)
            }
        }
    }
}
