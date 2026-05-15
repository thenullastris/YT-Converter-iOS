import Foundation
import SwiftUI

@MainActor
class DownloadViewModel: ObservableObject {
    @Published var urlText: String = ""
    @Published var selectedFormat: DownloadFormat = .mp3
    @Published var selectedQuality: DownloadQuality = .best
    @Published var status: DownloadStatus = .idle
    @Published var progress: Double = 0
    @Published var recentDownloads: [DownloadItem] = []
    @Published var showShareSheet: Bool = false
    @Published var shareURL: URL?

    private let historyKey = "download_history"

    init() {
        loadHistory()
    }

    var isDownloading: Bool {
        if case .downloading = status { return true }
        if case .processing = status { return true }
        return false
    }

    var statusText: String {
        switch status {
        case .idle: return "Ready"
        case .downloading(let p): return "Downloading... \(Int(p * 100))%"
        case .processing: return "Processing..."
        case .done: return "✅ Done!"
        case .failed(let e): return "❌ \(e)"
        }
    }

    var statusColor: Color {
        switch status {
        case .idle: return .gray
        case .downloading, .processing: return .blue
        case .done: return .green
        case .failed: return .red
        }
    }

    func startDownload() {
        guard !urlText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        status = .downloading(progress: 0)
        progress = 0

        DownloadService.shared.download(
            url: urlText,
            format: selectedFormat,
            quality: selectedQuality,
            onProgress: { [weak self] p in
                self?.progress = p
                self?.status = .downloading(progress: p)
            },
            onComplete: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let url):
                    self.status = .done(url: url)
                    self.progress = 1.0
                    self.addToHistory(url: url)
                    self.shareURL = url
                    self.showShareSheet = true
                case .failure(let error):
                    self.status = .failed(error: error.localizedDescription)
                }
            }
        )
    }

    private func addToHistory(url: URL) {
        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
        let size = attrs?[.size] as? Int64 ?? 0
        let sizeStr = ByteCountFormatter.string(fromByteCount: size, countStyle: .file)

        let item = DownloadItem(
            title: url.deletingPathExtension().lastPathComponent,
            format: selectedFormat.rawValue,
            quality: selectedQuality.rawValue,
            fileSize: sizeStr,
            filePath: url.path
        )
        recentDownloads.insert(item, at: 0)
        if recentDownloads.count > 20 { recentDownloads = Array(recentDownloads.prefix(20)) }
        saveHistory()
    }

    func shareItem(_ item: DownloadItem) {
        let url = URL(fileURLWithPath: item.filePath)
        if FileManager.default.fileExists(atPath: item.filePath) {
            shareURL = url
            showShareSheet = true
        }
    }

    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(recentDownloads) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([DownloadItem].self, from: data) {
            recentDownloads = decoded
        }
    }
}
