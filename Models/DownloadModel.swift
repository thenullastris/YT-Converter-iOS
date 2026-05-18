import Foundation

enum MediaType: String, CaseIterable, Identifiable {
    case video = "mp4"
    case audio = "mp3"
    var id: String { rawValue }
    var label: String {
        switch self {
        case .video: return "Video"
        case .audio: return "Audio"
        }
    }
    var icon: String {
        switch self {
        case .video: return "play.rectangle.fill"
        case .audio: return "music.note"
        }
    }
}

enum VideoQuality: String, CaseIterable, Identifiable {
    case best = "1080"
    case hd720 = "720"
    case sd480 = "480"
    case sd360 = "360"
    var id: String { rawValue }
    var label: String {
        switch self {
        case .best: return "Best"
        case .hd720: return "720p"
        case .sd480: return "480p"
        case .sd360: return "360p"
        }
    }
}

struct DownloadItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let url: String
    let mediaType: String
    let quality: String
    let date: Date
    var fileURL: String?

    init(id: UUID = UUID(), title: String, url: String, mediaType: String, quality: String, date: Date = Date(), fileURL: String? = nil) {
        self.id = id; self.title = title; self.url = url
        self.mediaType = mediaType; self.quality = quality
        self.date = date; self.fileURL = fileURL
    }
}

struct DownloadResponse: Codable {
    let success: Bool?
    let data: DownloadData?
    let message: String?

    struct DownloadData: Codable {
        let title: String?
        let downloadUrl: String?
        let fileSize: Int?
        let fileSizeMB: String?
        let format: String?
        let quality: String?
        let thumbnail: String?
        let duration: String?
    }
}