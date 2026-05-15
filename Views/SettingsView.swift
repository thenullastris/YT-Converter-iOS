import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultFormat") private var defaultFormat = "MP3"
    @AppStorage("defaultQuality") private var defaultQuality = "Best"

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                List {
                    Section("Defaults") {
                        Picker("Format", selection: $defaultFormat) {
                            ForEach(DownloadFormat.allCases, id: \.rawValue) { fmt in
                                Text(fmt.rawValue).tag(fmt.rawValue)
                            }
                        }
                        .tint(.red)

                        Picker("Quality", selection: $defaultQuality) {
                            ForEach(DownloadQuality.allCases, id: \.rawValue) { q in
                                Text(q.rawValue).tag(q.rawValue)
                            }
                        }
                        .tint(.red)
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    Section("About") {
                        HStack {
                            Text("App")
                            Spacer()
                            Text("YT Converter")
                                .foregroundStyle(.gray)
                        }
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(.gray)
                        }
                        HStack {
                            Text("Developer")
                            Spacer()
                            Text("KhinPhunnadet")
                                .foregroundStyle(.gray)
                        }
                        HStack {
                            Text("Brand")
                            Spacer()
                            Text("TheNullAstris")
                                .foregroundStyle(.gray)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    Section("Legal") {
                        Text("For personal use only. Respect YouTube's Terms of Service.")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
