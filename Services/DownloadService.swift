import Foundation

class DownloadService {
    static let shared = DownloadService()
    private let baseURL = "https://api.socialkit.dev/youtube/download"

    func fetchDownloadURL(youtubeURL: String, mediaType: MediaType, quality: VideoQuality) async throws -> DownloadResponse {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        let format = mediaType == .audio ? "mp3" : "mp4"
        let qualityStr = quality == .best ? "1080p" : "\(quality.rawValue)p"

        let body: [String: Any] = [
            "url": youtubeURL,
            "format": format,
            "quality": mediaType == .audio ? "128k" : qualityStr
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        // Debug: print raw response
        if let raw = String(data: data, encoding: .utf8) {
            print("SocialKit response (\(httpResponse.statusCode)): \(raw)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to parse error message
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = json["message"] as? String {
                throw NSError(domain: "DownloadService", code: httpResponse.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: msg])
            }
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(DownloadResponse.self, from: data)
        return decoded
    }

    func downloadFile(from urlString: String, filename: String, mediaType: MediaType) async throws -> URL {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (tempURL, _) = try await URLSession.shared.download(from: url)

        let ext = mediaType == .audio ? "mp3" : "mp4"
        let safe = filename
            .components(separatedBy: .init(charactersIn: "/\\:*?\"<>|"))
            .joined(separator: "_")
        let safeFilename = safe.isEmpty ? "download.\(ext)" : "\(safe).\(ext)"

        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destURL = docsDir.appendingPathComponent(safeFilename)

        if FileManager.default.fileExists(atPath: destURL.path) {
            try FileManager.default.removeItem(at: destURL)
        }
        try FileManager.default.moveItem(at: tempURL, to: destURL)
        return destURL
    }
}