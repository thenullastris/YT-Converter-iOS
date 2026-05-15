import SwiftUI

struct DownloadView: View {
    @StateObject private var vm = DownloadViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                RadialGradient(
                    colors: [Color.red.opacity(0.15), Color.clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 400
                ).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        headerSection

                        // URL input
                        urlInputSection

                        // Format
                        formatSection

                        // Quality
                        qualitySection

                        // Progress
                        if vm.isDownloading {
                            progressSection
                        }

                        // Download button
                        downloadButton

                        // Recent
                        if !vm.recentDownloads.isEmpty {
                            recentSection
                        }

                        // Footer
                        Text("Made by KhinPhunnadet")
                            .font(.caption2)
                            .foregroundStyle(.gray.opacity(0.5))
                            .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $vm.showShareSheet) {
            if let url = vm.shareURL {
                ShareSheet(url: url)
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 4) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.red)
                .padding(.top, 12)
            Text("YT Converter")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Download videos & audio")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
    }

    // MARK: - URL Input
    private var urlInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("YouTube URL", systemImage: "link")
                .font(.caption)
                .foregroundStyle(.gray)
                .textCase(.uppercase)

            HStack {
                TextField("Paste link here...", text: $vm.urlText)
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                if !vm.urlText.isEmpty {
                    Button {
                        vm.urlText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                } else {
                    Button("Paste") {
                        if let str = UIPasteboard.general.string {
                            vm.urlText = str
                        }
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Format
    private var formatSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Format")
                .font(.caption)
                .foregroundStyle(.gray)
                .textCase(.uppercase)

            HStack(spacing: 10) {
                ForEach(DownloadFormat.allCases, id: \.self) { fmt in
                    FormatCard(
                        format: fmt,
                        isSelected: vm.selectedFormat == fmt
                    ) {
                        vm.selectedFormat = fmt
                    }
                }
            }
        }
    }

    // MARK: - Quality
    private var qualitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quality")
                .font(.caption)
                .foregroundStyle(.gray)
                .textCase(.uppercase)

            HStack(spacing: 8) {
                ForEach(DownloadQuality.allCases, id: \.self) { q in
                    QualityPill(
                        quality: q,
                        isSelected: vm.selectedQuality == q,
                        isDisabled: vm.selectedFormat == .mp3 && q != .best
                    ) {
                        vm.selectedQuality = q
                    }
                }
            }
        }
    }

    // MARK: - Progress
    private var progressSection: some View {
        VStack(spacing: 8) {
            ProgressView(value: vm.progress)
                .tint(.red)
                .scaleEffect(x: 1, y: 2)
            Text(vm.statusText)
                .font(.caption)
                .foregroundStyle(vm.statusColor)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Download Button
    private var downloadButton: some View {
        Button {
            vm.startDownload()
        } label: {
            HStack {
                Image(systemName: "arrow.down.circle.fill")
                Text("Convert & Download")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: vm.isDownloading ? [Color.gray] : [Color.red, Color(red: 0.7, green: 0.1, blue: 0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .red.opacity(vm.isDownloading ? 0 : 0.4), radius: 12, y: 6)
        }
        .disabled(vm.isDownloading || vm.urlText.isEmpty)
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(.white)
    }

    // MARK: - Recent
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Downloads")
                .font(.caption)
                .foregroundStyle(.gray)
                .textCase(.uppercase)

            ForEach(vm.recentDownloads.prefix(5)) { item in
                RecentDownloadRow(item: item) {
                    vm.shareItem(item)
                }
            }
        }
    }
}
