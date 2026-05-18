import Foundation
import SwiftUI

enum DownloadState {
    case idle
    case fetching
    case downloading(progress: Double)
    case done(url: URL)
    case error(String)
}

@MainActor
class DownloadViewModel: ObservableObject {
    @Published var urlInput: String = ""
    @Published var selectedMediaType: MediaType = .video
    @Published var selectedQuality: VideoQuality = .best
    @Published var downloadState: DownloadState = .idle
    @Published var history: [DownloadItem] = []
    @Published var shareURL: URL? = nil
    @Published var showShareSheet: Bool = false

    init() {
        history = HistoryService.shared.load()
    }

    var isLoading: Bool {
        switch downloadState {
        case .fetching, .downloading: return true
        default: return false
        }
    }

    func startDownload() {
        let trimmed = urlInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard trimmed.contains("youtube.com") || trimmed.contains("youtu.be") else {
            downloadState = .error("Please enter a valid YouTube URL")
            return
        }
        Task { await performDownload(urlString: trimmed) }
    }

    private func performDownload(urlString: String) async {
        downloadState = .fetching

        do {
            let response = try await DownloadService.shared.fetchDownloadURL(
                youtubeURL: urlString,
                mediaType: selectedMediaType,
                quality: selectedQuality
            )

            guard response.success == true,
                  let data = response.data,
                  let downloadURL = data.downloadUrl else {
                let msg = response.message ?? "Failed to get download link"
                downloadState = .error(msg)
                return
            }

            downloadState = .downloading(progress: 0)

            let title = data.title ?? "download"
            let fileURL = try await DownloadService.shared.downloadFile(
                from: downloadURL,
                filename: title,
                mediaType: selectedMediaType
            )

            let item = DownloadItem(
                title: title,
                url: urlString,
                mediaType: selectedMediaType.rawValue,
                quality: selectedQuality.label
            )
            HistoryService.shared.add(item)
            history = HistoryService.shared.load()

            downloadState = .done(url: fileURL)
            shareURL = fileURL
            showShareSheet = true

        } catch {
            downloadState = .error(error.localizedDescription)
        }
    }

    func clearError() { downloadState = .idle }

    func deleteHistoryItem(id: UUID) {
        HistoryService.shared.delete(id: id)
        history = HistoryService.shared.load()
    }

    func clearHistory() {
        HistoryService.shared.clear()
        history = []
    }
}