import Foundation

class DownloadService {
    static let shared = DownloadService()

    private init() {}

    // yt-dlp binary path (bundled in app)
    private var ytdlpPath: String {
        Bundle.main.path(forResource: "yt-dlp", ofType: nil) ?? "/usr/local/bin/yt-dlp"
    }

    func download(
        url: String,
        format: DownloadFormat,
        quality: DownloadQuality,
        onProgress: @escaping (Double) -> Void,
        onComplete: @escaping (Result<URL, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let outputDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputTemplate = outputDir.appendingPathComponent("%(title)s.%(ext)s").path

            var args: [String] = [
                url,
                "-o", outputTemplate,
                "--no-playlist",
                "--newline"
            ]

            if format == .mp3 {
                args += [
                    "-x",
                    "--audio-format", "mp3",
                    "--audio-quality", "192K"
                ]
            } else {
                let formatStr: String
                switch quality {
                case .best: formatStr = "bestvideo+bestaudio/best"
                case .q720: formatStr = "bestvideo[height<=720]+bestaudio/best"
                case .q480: formatStr = "bestvideo[height<=480]+bestaudio/best"
                case .q360: formatStr = "bestvideo[height<=360]+bestaudio/best"
                }
                args += ["-f", formatStr, "--merge-output-format", "mp4"]
            }

            let process = Process()
            process.executableURL = URL(fileURLWithPath: self.ytdlpPath)
            process.arguments = args

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            pipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if let output = String(data: data, encoding: .utf8) {
                    // Parse progress from yt-dlp output
                    if output.contains("%") {
                        let components = output.components(separatedBy: "%")
                        if let percentStr = components.first?.components(separatedBy: " ").last,
                           let percent = Double(percentStr.trimmingCharacters(in: .whitespaces)) {
                            DispatchQueue.main.async { onProgress(percent / 100.0) }
                        }
                    }
                }
            }

            do {
                try process.run()
                process.waitUntilExit()

                if process.terminationStatus == 0 {
                    // Find the output file
                    let files = try FileManager.default.contentsOfDirectory(
                        at: outputDir,
                        includingPropertiesForKeys: [.creationDateKey],
                        options: .skipsHiddenFiles
                    )
                    let ext = format == .mp3 ? "mp3" : "mp4"
                    if let file = files.filter({ $0.pathExtension == ext })
                        .sorted(by: { (try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast) ?? Date.distantPast >
                                      (try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast) ?? Date.distantPast })
                        .first {
                        DispatchQueue.main.async { onComplete(.success(file)) }
                    } else {
                        DispatchQueue.main.async {
                            onComplete(.failure(NSError(domain: "YTConverter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Output file not found"])))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        onComplete(.failure(NSError(domain: "YTConverter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Download failed"])))
                    }
                }
            } catch {
                DispatchQueue.main.async { onComplete(.failure(error)) }
            }
        }
    }
}
