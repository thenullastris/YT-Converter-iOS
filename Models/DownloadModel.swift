import Foundation

enum DownloadFormat: String, CaseIterable {
    case mp3 = "MP3"
    case mp4 = "MP4"
}

enum DownloadQuality: String, CaseIterable {
    case best = "Best"
    case q720 = "720p"
    case q480 = "480p"
    case q360 = "360p"
}

enum DownloadStatus {
    case idle
    case downloading(progress: Double)
    case processing
    case done(url: URL)
    case failed(error: String)
}

struct DownloadItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let format: String
    let quality: String
    let fileSize: String
    let date: Date
    let filePath: String

    init(id: UUID = UUID(), title: String, format: String, quality: String, fileSize: String, date: Date = Date(), filePath: String) {
        self.id = id
        self.title = title
        self.format = format
        self.quality = quality
        self.fileSize = fileSize
        self.date = date
        self.filePath = filePath
    }
}
