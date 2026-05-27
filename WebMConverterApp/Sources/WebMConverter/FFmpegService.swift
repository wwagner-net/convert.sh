import Foundation

// MARK: - Video Info

struct VideoInfo {
    var width: Int
    var height: Int
    var duration: Double      // seconds
    var bitrateBps: Int       // 0 if unknown
    var hasAudio: Bool
    var hasVideo: Bool
}

// MARK: - FFmpegService

/// All FFmpeg/FFprobe interactions.  Thread-safe (no shared mutable state).
class FFmpegService {
    static let shared = FFmpegService()

    private(set) var ffmpegPath: String = ""
    private(set) var ffprobePath: String = ""

    private init() { detectBinaries() }

    // MARK: - Detection

    private func detectBinaries() {
        let candidates = [
            "/opt/homebrew/bin/ffmpeg",
            "/usr/local/bin/ffmpeg",
            "/usr/bin/ffmpeg"
        ]
        for path in candidates {
            if FileManager.default.isExecutableFile(atPath: path) {
                ffmpegPath  = path
                ffprobePath = path.replacingOccurrences(of: "/ffmpeg", with: "/ffprobe")
                return
            }
        }
        // Try `which`
        if let path = try? runSync("/usr/bin/which", args: ["ffmpeg"]),
           !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ffmpegPath  = path.trimmingCharacters(in: .whitespacesAndNewlines)
            ffprobePath = ffmpegPath.replacingOccurrences(of: "ffmpeg", with: "ffprobe")
        }
    }

    var isAvailable: Bool { !ffmpegPath.isEmpty }

    // MARK: - Thread count

    var threadCount: Int {
        let n = ProcessInfo.processInfo.activeProcessorCount
        return max(1, n)
    }

    // MARK: - Video info via ffprobe

    func videoInfo(for url: URL) throws -> VideoInfo {
        // --- has streams ---
        let videoStreams = (try? runSync(ffprobePath, args: [
            "-v", "quiet", "-select_streams", "v",
            "-show_entries", "stream=codec_type",
            "-of", "csv=s=x:p=0", url.path
        ])) ?? ""
        let audioStreams = (try? runSync(ffprobePath, args: [
            "-v", "quiet", "-select_streams", "a",
            "-show_entries", "stream=codec_type",
            "-of", "csv=s=x:p=0", url.path
        ])) ?? ""
        let hasVideo = !videoStreams.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasAudio = !audioStreams.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        // --- width ---
        let widthStr = (try? runSync(ffprobePath, args: [
            "-v", "quiet", "-select_streams", "v:0",
            "-show_entries", "stream=width",
            "-of", "csv=s=x:p=0", url.path
        ]))?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let width = Int(widthStr) ?? 0

        // --- height ---
        let heightStr = (try? runSync(ffprobePath, args: [
            "-v", "quiet", "-select_streams", "v:0",
            "-show_entries", "stream=height",
            "-of", "csv=s=x:p=0", url.path
        ]))?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let height = Int(heightStr) ?? 0

        // --- duration ---
        let durStr = (try? runSync(ffprobePath, args: [
            "-v", "quiet", "-show_entries", "format=duration",
            "-of", "csv=s=x:p=0", url.path
        ]))?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let duration = Double(durStr) ?? 0

        // --- bitrate: stream → format → estimate from file size ---
        var bitrate = 0
        if let bStr = try? runSync(ffprobePath, args: [
            "-v", "quiet", "-select_streams", "v:0",
            "-show_entries", "stream=bit_rate",
            "-of", "csv=s=x:p=0", url.path
        ]), let b = Int(bStr.trimmingCharacters(in: .whitespacesAndNewlines)), b > 0 {
            bitrate = b
        } else if let bStr = try? runSync(ffprobePath, args: [
            "-v", "quiet", "-show_entries", "format=bit_rate",
            "-of", "csv=s=x:p=0", url.path
        ]), let b = Int(bStr.trimmingCharacters(in: .whitespacesAndNewlines)), b > 0 {
            bitrate = b
        } else if duration > 0,
                  let attr = try? FileManager.default.attributesOfItem(atPath: url.path),
                  let fileSize = attr[.size] as? Int64 {
            bitrate = Int(Double(fileSize * 8) / duration)
        }

        return VideoInfo(
            width: width, height: height, duration: duration,
            bitrateBps: bitrate, hasAudio: hasAudio, hasVideo: hasVideo
        )
    }

    // MARK: - CRF Calculation

    func calculateCRF(type: VideoType, info: VideoInfo) -> Int {
        var crf = type.baseCRF
        if info.bitrateBps > 0 {
            crf += type.crfDelta(forBitrateBps: info.bitrateBps)
        }
        return max(23, min(50, crf))
    }

    // MARK: - Thumbnail Extraction

    func extractThumbnail(
        input: URL,
        output: URL,
        duration: Double,
        dryRun: Bool,
        log: @escaping (String) -> Void
    ) async throws -> Bool {
        if dryRun {
            log("  [DRY-RUN] Würde Thumbnail erstellen: \(output.lastPathComponent)")
            return true
        }

        let seekTime = duration >= 1.0 ? 1.0 : max(0.0, duration / 2.0)
        let seekStr  = String(format: "%.3f", seekTime)
        let tmp      = output.appendingPathExtension("tmp")

        let code = try await runFFmpeg(args: [
            "-y", "-ss", seekStr, "-i", input.path,
            "-vframes", "1", "-c:v", "libwebp", "-quality", "85",
            "-f", "webp", tmp.path
        ])

        guard code == 0, FileManager.default.fileExists(atPath: tmp.path) else {
            try? FileManager.default.removeItem(at: tmp)
            log("  ✗ Thumbnail-Fehler (exit \(code))")
            return false
        }
        if FileManager.default.fileExists(atPath: output.path) {
            try? FileManager.default.removeItem(at: output)
        }
        try FileManager.default.moveItem(at: tmp, to: output)
        let kb = (try? fileBytes(output)).map { "\($0 / 1024) KB" } ?? "?"
        log("  ✓ Thumbnail: \(kb)")
        return true
    }

    // MARK: - Standard Conversion (with iterative CRF size-check)

    /// Returns true when output was successfully created and is smaller than input.
    func convertWithSizeCheck(
        input: URL,
        output: URL,
        scaleWidth: Int?,        // nil = original resolution
        baseCRF: Int,
        audioBitrateKbps: Int,
        speed: Int,
        dryRun: Bool,
        log: @escaping (String) -> Void,
        cancelled: @escaping () -> Bool
    ) async throws -> Bool {

        if dryRun {
            let scale = scaleWidth.map { "\($0)px" } ?? "original"
            log("  [DRY-RUN] Würde erstellen: \(output.lastPathComponent)  (CRF \(baseCRF), \(scale))")
            return true
        }

        let inputBytes  = (try? fileBytes(input)) ?? 0
        let tmp         = output.appendingPathExtension("tmp")
        var currentCRF  = baseCRF
        let maxCRF      = 50
        var attempt     = 0

        while true {
            if cancelled() { return false }

            let scaleArgs: [String]
            if let w = scaleWidth {
                scaleArgs = ["-vf", "scale=\(w):-1"]
            } else {
                scaleArgs = []
            }

            let args: [String] = [
                "-y", "-i", input.path
            ] + scaleArgs + [
                "-c:v", "libvpx-vp9", "-b:v", "0", "-crf", "\(currentCRF)",
                "-threads", "\(threadCount)", "-speed", "\(speed)",
                "-tile-columns", "1", "-row-mt", "1",
                "-c:a", "libopus", "-b:a", "\(audioBitrateKbps)k",
                "-f", "webm", tmp.path
            ]

            let exitCode = try await runFFmpeg(args: args)
            guard exitCode == 0, FileManager.default.fileExists(atPath: tmp.path) else {
                try? FileManager.default.removeItem(at: tmp)
                log("  ✗ FFmpeg-Fehler (exit \(exitCode), CRF \(currentCRF))")
                return false
            }

            let outBytes = (try? fileBytes(tmp)) ?? 0

            if outBytes <= inputBytes || currentCRF >= maxCRF {
                if outBytes > inputBytes {
                    try? FileManager.default.removeItem(at: tmp)
                    log("  ⚠ WebM (\(formatBytes(outBytes))) größer als Original (\(formatBytes(inputBytes))) → übersprungen")
                    return false
                }
                if FileManager.default.fileExists(atPath: output.path) {
                    try? FileManager.default.removeItem(at: output)
                }
                try FileManager.default.moveItem(at: tmp, to: output)
                let pct = inputBytes > 0 ? Int(Double(outBytes) * 100 / Double(inputBytes)) : 0
                log("  ✓ \(output.lastPathComponent): \(formatBytes(outBytes)) (\(pct)% vom Original, CRF \(currentCRF))")
                return true
            }

            // Output still larger – raise CRF and retry
            try? FileManager.default.removeItem(at: tmp)
            attempt += 1
            currentCRF = min(currentCRF + 3, maxCRF)
            log("  ⚠ WebM größer → Versuch \(attempt + 1) mit CRF \(currentCRF)")
        }
    }

    // MARK: - 50 % Two-Pass Conversion

    func convertTo50Percent(
        input: URL,
        output: URL,
        scaleWidth: Int?,
        audioBitrateKbps: Int,
        speed: Int,
        dryRun: Bool,
        log: @escaping (String) -> Void,
        cancelled: @escaping () -> Bool
    ) async throws -> Bool {

        if dryRun {
            log("  [DRY-RUN] Würde erstellen: \(output.lastPathComponent) (50%, Two-Pass)")
            return true
        }

        guard let inputSize = try? fileBytes(input), inputSize > 0 else {
            log("  ✗ Eingabe-Dateigröße unbekannt")
            return false
        }

        // Duration via ffprobe
        let durStr = (try? runSync(ffprobePath, args: [
            "-v", "quiet", "-show_entries", "format=duration",
            "-of", "csv=s=x:p=0", input.path
        ]))?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard let duration = Double(durStr), duration > 0 else {
            log("  ✗ Kann Dauer nicht ermitteln")
            return false
        }

        let targetBytes = inputSize / 2
        let targetBitrateKbps = max(100, Int(Double(targetBytes * 8) / duration / 1000) - audioBitrateKbps)
        log("  → Ziel: \(formatBytes(targetBytes)) (~50%), Video-Bitrate: \(targetBitrateKbps)k")

        let tmp     = output.appendingPathExtension("tmp")
        let logBase = output.deletingPathExtension().path + ".passlog"

        let scaleArgs: [String] = scaleWidth.map { ["-vf", "scale=\($0):-1"] } ?? []

        // Pass 1
        if cancelled() { return false }
        log("  → Pass 1/2 …")
        let pass1Args: [String] = [
            "-y", "-i", input.path
        ] + scaleArgs + [
            "-c:v", "libvpx-vp9", "-b:v", "\(targetBitrateKbps)k",
            "-pass", "1", "-passlogfile", logBase,
            "-threads", "\(threadCount)", "-speed", "4",
            "-tile-columns", "1", "-row-mt", "1",
            "-an", "-f", "webm", "/dev/null"
        ]
        let code1 = try await runFFmpeg(args: pass1Args)
        guard code1 == 0 else {
            cleanPassLog(logBase)
            log("  ✗ Pass 1 fehlgeschlagen (exit \(code1))")
            return false
        }

        // Pass 2
        if cancelled() { cleanPassLog(logBase); return false }
        log("  → Pass 2/2 …")
        let pass2Args: [String] = [
            "-y", "-i", input.path
        ] + scaleArgs + [
            "-c:v", "libvpx-vp9", "-b:v", "\(targetBitrateKbps)k",
            "-pass", "2", "-passlogfile", logBase,
            "-threads", "\(threadCount)", "-speed", "\(speed)",
            "-tile-columns", "1", "-row-mt", "1",
            "-c:a", "libopus", "-b:a", "\(audioBitrateKbps)k",
            "-f", "webm", tmp.path
        ]
        let code2 = try await runFFmpeg(args: pass2Args)
        cleanPassLog(logBase)

        guard code2 == 0, FileManager.default.fileExists(atPath: tmp.path) else {
            try? FileManager.default.removeItem(at: tmp)
            log("  ✗ Pass 2 fehlgeschlagen (exit \(code2))")
            return false
        }

        let finalSize = (try? fileBytes(tmp)) ?? 0
        let pct = inputSize > 0 ? Int(Double(finalSize) * 100 / Double(inputSize)) : 0
        if FileManager.default.fileExists(atPath: output.path) {
            try? FileManager.default.removeItem(at: output)
        }
        try FileManager.default.moveItem(at: tmp, to: output)
        log("  ✓ \(output.lastPathComponent): \(formatBytes(finalSize)) (\(pct)%, \(targetBitrateKbps)k)")
        return true
    }

    // MARK: - Square Conversion

    func convertSquare(
        input: URL,
        output: URL,
        size: Int,
        crf: Int,
        audioBitrateKbps: Int,
        speed: Int,
        dryRun: Bool,
        log: @escaping (String) -> Void,
        cancelled: @escaping () -> Bool
    ) async throws -> Bool {

        if dryRun {
            log("  [DRY-RUN] Würde erstellen: \(output.lastPathComponent) (\(size)×\(size) quadratisch)")
            return true
        }

        let inputBytes = (try? fileBytes(input)) ?? 0
        let tmp = output.appendingPathExtension("tmp")

        if cancelled() { return false }
        let args: [String] = [
            "-y", "-i", input.path,
            "-vf", "scale=\(size):\(size):force_original_aspect_ratio=increase,crop=\(size):\(size)",
            "-c:v", "libvpx-vp9", "-b:v", "0", "-crf", "\(crf)",
            "-threads", "\(threadCount)", "-speed", "\(speed)",
            "-tile-columns", "1", "-row-mt", "1",
            "-c:a", "libopus", "-b:a", "\(audioBitrateKbps)k",
            "-f", "webm", tmp.path
        ]

        let exitCode = try await runFFmpeg(args: args)
        guard exitCode == 0, FileManager.default.fileExists(atPath: tmp.path) else {
            try? FileManager.default.removeItem(at: tmp)
            log("  ✗ Quadrat-Konvertierung fehlgeschlagen (exit \(exitCode))")
            return false
        }

        let outBytes = (try? fileBytes(tmp)) ?? 0
        if outBytes > inputBytes {
            try? FileManager.default.removeItem(at: tmp)
            log("  ⚠ Quadrat-WebM größer als Original → übersprungen")
            return false
        }

        if FileManager.default.fileExists(atPath: output.path) {
            try? FileManager.default.removeItem(at: output)
        }
        try FileManager.default.moveItem(at: tmp, to: output)
        let pct = inputBytes > 0 ? Int(Double(outBytes) * 100 / Double(inputBytes)) : 0
        log("  ✓ \(output.lastPathComponent): \(formatBytes(outBytes)) (\(pct)%, \(size)×\(size)px)")
        return true
    }

    // MARK: - Helpers

    private func runFFmpeg(args: [String]) async throws -> Int32 {
        try await runAsync(ffmpegPath, args: args)
    }

    func runAsync(_ path: String, args: [String]) async throws -> Int32 {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = args
            // Suppress output – progress parsing via stderr would be added here
            process.standardOutput = Pipe()
            process.standardError  = Pipe()
            process.terminationHandler = { p in
                continuation.resume(returning: p.terminationStatus)
            }
            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func runSync(_ path: String, args: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError  = Pipe()
        try process.run()
        process.waitUntilExit()
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    }

    private func fileBytes(_ url: URL) throws -> Int64 {
        let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
        return attrs[.size] as? Int64 ?? 0
    }

    private func cleanPassLog(_ base: String) {
        for suffix in ["-0.log", "-0.log.mbtree"] {
            try? FileManager.default.removeItem(atPath: base + suffix)
        }
    }

    func formatBytes(_ n: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle  = .file
        return formatter.string(fromByteCount: n)
    }
}
