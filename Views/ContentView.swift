import SwiftUI

struct ContentView: View {
    @StateObject private var vm = DownloadViewModel()
    @State private var showHistory = false

    var body: some View {
        ZStack {
            FloatingOrbsBackground()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerView

                    // URL Input Card
                    urlInputCard

                    // Type & Quality Card
                    optionsCard

                    // Download Button
                    GlassButton(
                        title: "Download",
                        icon: "arrow.down.circle.fill",
                        isLoading: vm.isLoading
                    ) {
                        vm.startDownload()
                    }
                    .padding(.horizontal, 20)

                    // State feedback
                    stateView

                    // History preview
                    if !vm.history.isEmpty {
                        historyPreview
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
        .sheet(isPresented: $vm.showShareSheet) {
            if let url = vm.shareURL {
                ShareSheet(items: [url])
            }
        }
        .sheet(isPresented: $showHistory) {
            HistoryView(vm: vm)
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("YT Converter")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Download videos & audio")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Button {
                showHistory = true
            } label: {
                Image(systemName: "clock.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(12)
                    .background {
                        Circle()
                            .fill(.white.opacity(0.1))
                            .overlay {
                                Circle().strokeBorder(.white.opacity(0.15), lineWidth: 1)
                            }
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - URL Input
    private var urlInputCard: some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: "link")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.4))

                TextField("", text: $vm.urlInput, prompt: Text("Paste YouTube URL")
                    .foregroundColor(.white.opacity(0.3)))
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)

                if !vm.urlInput.isEmpty {
                    Button {
                        vm.urlInput = ""
                        vm.clearError()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Options
    private var optionsCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                // Media type
                GlassSegmentPicker(
                    options: MediaType.self,
                    selection: $vm.selectedMediaType,
                    labelForOption: { $0.label },
                    iconForOption: { $0.icon }
                )

                // Quality (only for video)
                if vm.selectedMediaType == .video {
                    Divider().overlay(.white.opacity(0.1))

                    HStack {
                        Text("Quality")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                        Spacer()
                        HStack(spacing: 8) {
                            ForEach(VideoQuality.allCases) { q in
                                let isSelected = vm.selectedQuality == q
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        vm.selectedQuality = q
                                    }
                                } label: {
                                    Text(q.label)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(isSelected ? .white : .white.opacity(0.4))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background {
                                            if isSelected {
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .fill(.white.opacity(0.15))
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                            .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                                                    }
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.selectedMediaType)
    }

    // MARK: - State feedback
    @ViewBuilder
    private var stateView: some View {
        switch vm.downloadState {
        case .error(let msg):
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red.opacity(0.8))
                Text(msg)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(2)
                Spacer()
                Button { vm.clearError() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.red.opacity(0.1))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(.red.opacity(0.25), lineWidth: 1)
                    }
            }
            .padding(.horizontal, 20)
            .transition(.move(edge: .top).combined(with: .opacity))

        case .done:
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green.opacity(0.9))
                Text("Download complete!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.green.opacity(0.1))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(.green.opacity(0.25), lineWidth: 1)
                    }
            }
            .padding(.horizontal, 20)
            .transition(.move(edge: .top).combined(with: .opacity))

        default:
            EmptyView()
        }
    }

    // MARK: - History preview
    private var historyPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                Button { showHistory = true } label: {
                    Text("See all")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .buttonStyle(.plain)
            }

            ForEach(vm.history.prefix(3)) { item in
                HistoryRow(item: item)
            }
        }
        .padding(.horizontal, 20)
    }
}
