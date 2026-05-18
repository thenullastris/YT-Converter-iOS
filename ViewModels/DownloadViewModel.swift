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

        Task {
            await performDownload(urlString: trimmed)
        }
    }

    private func performDownload(urlString: String) async {
        downloadState = .fetching

        do {
            let cobaltResponse = try await CobaltService.shared.fetchDownloadURL(
                youtubeURL: urlString,
                mediaType: selectedMediaType,
                quality: selectedQuality
            )

            let validStatuses = ["tunnel", "redirect", "stream", "picker"]
            guard validStatuses.contains(cobaltResponse.status),
                  let downloadURL = cobaltResponse.url else {
                let msg = cobaltResponse.error?.code ?? cobaltResponse.text ?? "cobalt error: \(cobaltResponse.status)"
                downloadState = .error(msg)
                return
            }

            downloadState = .downloading(progress: 0)

            let filename = cobaltResponse.filename ?? "download"
            let cleanFilename = (filename as NSString).deletingPathExtension

            let fileURL = try await CobaltService.shared.downloadFile(
                from: downloadURL,
                filename: cleanFilename,
                mediaType: selectedMediaType
            )

            let item = DownloadItem(
                title: cleanFilename,
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

    func clearError() {
        downloadState = .idle
    }

    func deleteHistoryItem(id: UUID) {
        HistoryService.shared.delete(id: id)
        history = HistoryService.shared.load()
    }

    func clearHistory() {
        HistoryService.shared.clear()
        history = []
    }
}