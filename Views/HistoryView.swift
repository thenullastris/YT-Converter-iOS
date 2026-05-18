import SwiftUI

struct HistoryView: View {
    @ObservedObject var vm: DownloadViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            FloatingOrbsBackground()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Downloads")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    if !vm.history.isEmpty {
                        Button {
                            withAnimation { vm.clearHistory() }
                        } label: {
                            Text("Clear")
                                .font(.system(size: 14))
                                .foregroundStyle(.red.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                    }
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)

                if vm.history.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.2))
                        Text("No downloads yet")
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(vm.history) { item in
                                HistoryRow(item: item)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            vm.deleteHistoryItem(id: item.id)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

struct HistoryRow: View {
    let item: DownloadItem

    var body: some View {
        GlassCard {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(item.mediaType == "mp3" ? Color.purple.opacity(0.2) : Color.red.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: item.mediaType == "mp3" ? "music.note" : "play.rectangle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(item.mediaType == "mp3" ? .purple : .red)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                    Text("\(item.mediaType.uppercased()) • \(item.quality) • \(item.date.formatted(.relative(presentation: .named)))")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.35))
                }

                Spacer()
            }
            .padding(12)
        }
    }
}
