import Foundation
import Combine

// MARK: - VideoType

enum VideoType: String, CaseIterable, Identifiable {
    case screencast, animation, nature, action, film

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .screencast: return "Screencast / Tutorial"
        case .animation:  return "Animation / Motion Graphics"
        case .nature:     return "Natur / Interview / Vlog"
        case .action:     return "Action / Sport"
        case .film:       return "Film / Cinematic"
        }
    }

    /// Base CRF value – lower = better quality / larger file
    var baseCRF: Int {
        switch self {
        case .screencast: return 40
        case .animation:  return 37
        case .nature:     return 33
        case .action:     return 29
        case .film:       return 26
        }
    }

    /// Audio bitrate in kbps
    var audioBitrateKbps: Int {
        switch self {
        case .screencast: return 64
        case .animation:  return 96
        case .nature:     return 128
        case .action:     return 128
        case .film:       return 160
        }
    }

    /// CRF delta based on source bitrate (mirrors bash logic)
    func crfDelta(forBitrateBps bitrate: Int) -> Int {
        switch bitrate {
        case ..<2_000_000:  return -4
        case ..<5_000_000:  return -2
        case ..<10_000_000: return  0
        default:            return +3
        }
    }

    /// CRF delta based on output resolution width
    static func crfDelta(forOutputWidth width: Int) -> Int {
        switch width {
        case 1400...: return 2
        case 1000...: return 3
        case 720...:  return 4
        default:      return 5
        }
    }
}

// MARK: - ConversionVariant

enum ConversionVariant: String, CaseIterable, Identifiable, Hashable {
    case original   = "original"
    case percent50  = "50percent"
    case square     = "square"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .original:  return "Original"
        case .percent50: return "50 % Dateigröße"
        case .square:    return "Quadratisch (1:1)"
        }
    }

    var description: String {
        switch self {
        case .original:  return "Original-Auflösung, optimierter CRF"
        case .percent50: return "Two-Pass, ~50 % der Quelldatei"
        case .square:    return "Quadratisch (crop), kleinste Auflösung"
        }
    }
}

// MARK: - ConversionSettings

class ConversionSettings: ObservableObject {
    @Published var videoType: VideoType = .film
    @Published var speed: Int = 2                       // 0 (slow/best) … 5 (fast)
    @Published var selectedVariants: Set<ConversionVariant> = [.original]
    @Published var customResolutionsText: String = ""  // "1400,1000,500" or ""
    @Published var createThumbnail: Bool = true
    @Published var dryRun: Bool = false
    @Published var customOutputURL: URL? = nil          // nil = next to input

    // Parsed resolutions, empty = use defaults [1400, 1000, 500]
    var customResolutions: [Int] {
        guard !customResolutionsText.isEmpty else { return [] }
        return customResolutionsText
            .split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            .filter { $0 > 0 }
    }

    var effectiveResolutions: [Int] {
        let parsed = customResolutions
        return parsed.isEmpty ? [1400, 1000, 500] : parsed
    }
}

// MARK: - VideoFile (Observable job model)

enum FileStatus: Equatable {
    case pending
    case processing(step: String)
    case done(stats: ConversionStats)
    case failed(reason: String)
    case cancelled
}

struct ConversionStats: Equatable {
    var filesCreated: Int = 0
    var filesSkipped: Int = 0
    var inputBytes: Int64 = 0
    var outputBytes: Int64 = 0
    var thumbnailCreated: Bool = false

    var compressionPercent: Double {
        guard inputBytes > 0 else { return 0 }
        return (1.0 - Double(outputBytes) / Double(inputBytes)) * 100
    }
}

@MainActor
class VideoFile: ObservableObject, Identifiable, Hashable {
    let id = UUID()
    let url: URL

    nonisolated static func == (lhs: VideoFile, rhs: VideoFile) -> Bool { lhs.id == rhs.id }
    nonisolated func hash(into hasher: inout Hasher) { hasher.combine(id) }

    @Published var status: FileStatus = .pending
    @Published var logLines: [String] = []

    var filename: String { url.lastPathComponent }
    var nameWithoutExtension: String { url.deletingPathExtension().lastPathComponent }

    init(url: URL) {
        self.url = url
    }

    func appendLog(_ line: String) {
        logLines.append(line)
    }
}
