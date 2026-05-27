import Foundation
import AppKit

/// Orchestrates the conversion queue.  All published state is mutated on the main actor.
@MainActor
class ConversionManager: ObservableObject {

    @Published var files: [VideoFile] = []
    @Published var isConverting: Bool = false
    @Published var currentIndex: Int = -1

    // Statistics (last run)
    @Published var lastStats = ConversionStats()

    private var conversionTask: Task<Void, Never>?
    private var _cancelled = false

    // MARK: - Queue Management

    func addFiles(_ urls: [URL]) {
        let accepted = urls.filter {
            ["mp4", "mov"].contains($0.pathExtension.lowercased())
        }
        let existing = Set(files.map { $0.url })
        for url in accepted where !existing.contains(url) {
            files.append(VideoFile(url: url))
        }
    }

    func remove(_ file: VideoFile) {
        files.removeAll { $0.id == file.id }
    }

    func clearAll() {
        guard !isConverting else { return }
        files.removeAll()
    }

    // MARK: - Conversion

    func startConversion(settings: ConversionSettings) {
        guard !isConverting else { return }
        guard !files.isEmpty else { return }
        guard FFmpegService.shared.isAvailable else { return }

        _cancelled = false
        isConverting = true
        lastStats = ConversionStats()

        conversionTask = Task { [weak self] in
            guard let self else { return }
            await self.runAllFiles(settings: settings)
            await MainActor.run {
                self.isConverting = false
                self.currentIndex = -1
            }
        }
    }

    func cancelAll() {
        _cancelled = true
        conversionTask?.cancel()
        conversionTask = nil
        isConverting = false
        currentIndex = -1
        // Mark pending files as cancelled
        for f in files {
            if case .pending = f.status { f.status = .cancelled }
            if case .processing = f.status { f.status = .cancelled }
        }
    }

    // MARK: - Internal

    private func runAllFiles(settings: ConversionSettings) async {
        let ffmpeg = FFmpegService.shared

        for (idx, file) in files.enumerated() {
            if _cancelled { break }

            await MainActor.run { [weak self] in
                self?.currentIndex = idx
                file.status = .processing(step: "Analysiere …")
                file.logLines = []
            }

            var stats = ConversionStats()

            do {
                // ── Resolve output directory ──────────────────────────
                let outputDir: URL
                if let custom = settings.customOutputURL {
                    outputDir = custom
                } else {
                    outputDir = file.url.deletingLastPathComponent()
                        .appendingPathComponent("output")
                }
                try FileManager.default.createDirectory(
                    at: outputDir, withIntermediateDirectories: true)

                // ── Video Info ─────────────────────────────────────────
                let info: VideoInfo
                do {
                    info = try ffmpeg.videoInfo(for: file.url)
                } catch {
                    throw NSError(domain: "FFprobe", code: 1,
                                  userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
                }

                guard info.hasVideo else {
                    throw NSError(domain: "FFprobe", code: 2,
                                  userInfo: [NSLocalizedDescriptionKey: "Keine Video-Spur gefunden"])
                }

                let log: (String) -> Void = { [weak self, weak file] line in
                    _ = Task { @MainActor in
                        file?.appendLog(line)
                        self?.objectWillChange.send()
                    }
                }

                let cancelled = { [weak self] in self?._cancelled ?? true }

                stats.inputBytes = (try? FileManager.default.attributesOfItem(
                    atPath: file.url.path)[.size] as? Int64) ?? 0

                // ── Thumbnail ─────────────────────────────────────────
                if settings.createThumbnail {
                    await setStep(file, "Thumbnail …")
                    log("→ Extrahiere WebP Thumbnail …")
                    let thumbOut = outputDir
                        .appendingPathComponent("\(file.nameWithoutExtension)_thumbnail.webp")
                    let ok = try await ffmpeg.extractThumbnail(
                        input: file.url, output: thumbOut,
                        duration: info.duration, dryRun: settings.dryRun, log: log)
                    stats.thumbnailCreated = ok
                }

                let baseCRF       = ffmpeg.calculateCRF(type: settings.videoType, info: info)
                let audioBitrate  = settings.videoType.audioBitrateKbps
                let speed         = settings.speed
                let name          = file.nameWithoutExtension

                log("→ Original-Breite: \(info.width)px, Bitrate: \(info.bitrateBps/1000)k, CRF: \(baseCRF)")
                log("→ Typ: \(settings.videoType.displayName), Audio: \(audioBitrate)k, Speed: \(speed)")

                // ── Original variant ──────────────────────────────────
                let useCustomRes = !settings.customResolutions.isEmpty

                if !useCustomRes && settings.selectedVariants.contains(.original) {
                    await setStep(file, "Original …")
                    log("→ Erstelle _original.webm …")
                    let out = outputDir.appendingPathComponent("\(name)_original.webm")
                    let ok = try await ffmpeg.convertWithSizeCheck(
                        input: file.url, output: out,
                        scaleWidth: nil, baseCRF: baseCRF,
                        audioBitrateKbps: audioBitrate, speed: speed,
                        dryRun: settings.dryRun, log: log, cancelled: cancelled)
                    if ok { stats.filesCreated += 1 } else { stats.filesSkipped += 1 }
                    if let s = try? FileManager.default.attributesOfItem(atPath: out.path)[.size] as? Int64 {
                        stats.outputBytes += s
                    }
                }

                // ── 50 % variant ──────────────────────────────────────
                if !useCustomRes && settings.selectedVariants.contains(.percent50) {
                    await setStep(file, "50% Two-Pass …")
                    log("→ Erstelle _50percent.webm (Two-Pass) …")
                    let out = outputDir.appendingPathComponent("\(name)_50percent.webm")
                    let ok = try await ffmpeg.convertTo50Percent(
                        input: file.url, output: out,
                        scaleWidth: nil,
                        audioBitrateKbps: audioBitrate, speed: speed,
                        dryRun: settings.dryRun, log: log, cancelled: cancelled)
                    if ok { stats.filesCreated += 1 } else { stats.filesSkipped += 1 }
                    if let s = try? FileManager.default.attributesOfItem(atPath: out.path)[.size] as? Int64 {
                        stats.outputBytes += s
                    }
                }

                // ── Resolution variants ───────────────────────────────
                let resolutions = settings.effectiveResolutions
                for res in resolutions {
                    if cancelled() { break }
                    guard info.width > res else {
                        log("  → Überspringe \(res)px (Original \(info.width)px zu schmal)")
                        stats.filesSkipped += 1
                        continue
                    }

                    let sizeDelta = VideoType.crfDelta(forOutputWidth: res)
                    let crf = min(50, baseCRF + sizeDelta)

                    await setStep(file, "\(res)px …")
                    log("→ Erstelle \(res)px-Version (CRF \(crf)) …")
                    let out = outputDir.appendingPathComponent("\(name)_\(res)px.webm")
                    let ok = try await ffmpeg.convertWithSizeCheck(
                        input: file.url, output: out,
                        scaleWidth: res, baseCRF: crf,
                        audioBitrateKbps: audioBitrate, speed: speed,
                        dryRun: settings.dryRun, log: log, cancelled: cancelled)
                    if ok { stats.filesCreated += 1 } else { stats.filesSkipped += 1 }
                    if let s = try? FileManager.default.attributesOfItem(atPath: out.path)[.size] as? Int64 {
                        stats.outputBytes += s
                    }
                }

                // ── Square variant ────────────────────────────────────
                if settings.selectedVariants.contains(.square) {
                    let smallestRes = settings.effectiveResolutions.min() ?? 500
                    let crfSq = min(50, baseCRF + 5)
                    await setStep(file, "\(smallestRes)px Quadrat …")
                    log("→ Erstelle \(smallestRes)×\(smallestRes)px Quadrat …")
                    let out = outputDir.appendingPathComponent("\(name)_\(smallestRes)px_square.webm")
                    let ok = try await ffmpeg.convertSquare(
                        input: file.url, output: out,
                        size: smallestRes, crf: crfSq,
                        audioBitrateKbps: audioBitrate, speed: speed,
                        dryRun: settings.dryRun, log: log, cancelled: cancelled)
                    if ok { stats.filesCreated += 1 } else { stats.filesSkipped += 1 }
                    if let s = try? FileManager.default.attributesOfItem(atPath: out.path)[.size] as? Int64 {
                        stats.outputBytes += s
                    }
                }

                await MainActor.run {
                    file.status = .done(stats: stats)
                    self.lastStats.filesCreated  += stats.filesCreated
                    self.lastStats.filesSkipped  += stats.filesSkipped
                    self.lastStats.inputBytes    += stats.inputBytes
                    self.lastStats.outputBytes   += stats.outputBytes
                    if stats.thumbnailCreated { self.lastStats.thumbnailCreated = true }
                }

                // Open output folder in Finder after first successful file
                if idx == 0 && !settings.dryRun {
                    let outputDir2: URL
                    if let custom = settings.customOutputURL {
                        outputDir2 = custom
                    } else {
                        outputDir2 = file.url.deletingLastPathComponent()
                            .appendingPathComponent("output")
                    }
                    NSWorkspace.shared.open(outputDir2)
                }

            } catch {
                await MainActor.run {
                    file.status = .failed(reason: error.localizedDescription)
                    file.appendLog("✗ \(error.localizedDescription)")
                }
            }
        }
    }

    private func setStep(_ file: VideoFile, _ step: String) async {
        await MainActor.run { file.status = .processing(step: step) }
    }
}
