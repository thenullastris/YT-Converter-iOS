import Foundation

class CobaltService {
    static let shared = CobaltService()
    private let baseURL = "https://api.cobalt.tools"

    func fetchDownloadURL(youtubeURL: String, mediaType: MediaType, quality: VideoQuality) async throws -> CobaltResponse {
        guard let url = URL(string: "\(baseURL)/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        var body: [String: Any] = [
            "url": youtubeURL,
            "downloadMode": mediaType == .audio ? "audio" : "auto",
        ]

        if mediaType == .video {
            body["videoQuality"] = quality.rawValue
        }

        if mediaType == .audio {
            body["audioFormat"] = "mp3"
            body["audioBitrate"] = "320"
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let cobaltResponse = try JSONDecoder().decode(CobaltResponse.self, from: data)
        return cobaltResponse
    }

    func downloadFile(from urlString: String, filename: String, mediaType: MediaType) async throws -> URL {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (tempURL, _) = try await URLSession.shared.download(from: url)

        let ext = mediaType == .audio ? "mp3" : "mp4"
        let safeFilename = filename.isEmpty ? "download.\(ext)" : "\(filename).\(ext)"

        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destURL = docsDir.appendingPathComponent(safeFilename)

        if FileManager.default.fileExists(atPath: destURL.path) {
            try FileManager.default.removeItem(at: destURL)
        }
        try FileManager.default.moveItem(at: tempURL, to: destURL)

        return destURL
    }
}
