import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - ContentView (main window)

struct ContentView: View {
    @EnvironmentObject var manager: ConversionManager
    @EnvironmentObject var settings: ConversionSettings

    @State private var showSettings   = false
    @State private var isDropTargeted = false
    @State private var showLog        = false
    @State private var selectedFile: VideoFile? = nil

    // FFmpeg availability
    private var ffmpegMissing: Bool { !FFmpegService.shared.isAvailable }

    var body: some View {
        ZStack {
            // Background
            Color(nsColor: .windowBackgroundColor).ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Toolbar ──────────────────────────────────────────────
                toolbar

                Divider()

                // ── FFmpeg warning banner ─────────────────────────────────
                if ffmpegMissing {
                    ffmpegBanner
                }

                // ── Drop zone OR file list ────────────────────────────────
                if manager.files.isEmpty {
                    dropZone
                } else {
                    fileListView
                }

                Divider()

                // ── Controls ─────────────────────────────────────────────
                controlBar

                // ── Log ──────────────────────────────────────────────────
                if showLog {
                    Divider()
                    logPanel
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(settings)
        }
        .onDrop(of: [UTType.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
        }
        // Receive open-settings request from the menu bar (⌘,)
        .onReceive(NotificationCenter.default.publisher(for: .openSettings)) { _ in
            showSettings = true
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(spacing: 12) {
            // App icon + title
            HStack(spacing: 8) {
                Image(systemName: "film.stack")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Text("WebM Converter")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Spacer()

            // File count badge
            if !manager.files.isEmpty {
                Text("\(manager.files.count) Datei\(manager.files.count == 1 ? "" : "en")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(.quaternary, in: Capsule())
            }

            // Settings button
            Button {
                showSettings.toggle()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.body)
            }
            .buttonStyle(.plain)
            .help("Einstellungen  ⌘,")

            // Log toggle
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showLog.toggle() }
            } label: {
                Image(systemName: showLog ? "terminal.fill" : "terminal")
                    .font(.body)
                    .foregroundStyle(showLog ? .blue : .secondary)
            }
            .buttonStyle(.plain)
            .help("Log anzeigen / verstecken")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - FFmpeg warning

    private var ffmpegBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            VStack(alignment: .leading, spacing: 2) {
                Text("FFmpeg nicht gefunden")
                    .fontWeight(.medium)
                Text("brew install ffmpeg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.yellow.opacity(0.12))
    }

    // MARK: - Drop Zone

    private var dropZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    isDropTargeted
                        ? AnyShapeStyle(LinearGradient(colors: [.purple, .blue],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                        : AnyShapeStyle(Color.secondary.opacity(0.25)),
                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                )
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isDropTargeted
                              ? Color.accentColor.opacity(0.06)
                              : Color.clear)
                )
                .padding(24)
                .animation(.easeInOut(duration: 0.15), value: isDropTargeted)

            VStack(spacing: 16) {
                Image(systemName: isDropTargeted ? "arrow.down.circle.fill" : "arrow.down.doc")
                    .font(.system(size: 52, weight: .thin))
                    .foregroundStyle(
                        isDropTargeted
                            ? LinearGradient(colors: [.purple, .blue],
                                startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [.secondary],
                                startPoint: .top, endPoint: .bottom)
                    )
                    .animation(.spring(duration: 0.3), value: isDropTargeted)
                    .scaleEffect(isDropTargeted ? 1.1 : 1.0)

                VStack(spacing: 6) {
                    Text("MP4 / MOV Videos hierher ziehen")
                        .font(.title3).fontWeight(.medium)
                    Text("oder")
                        .foregroundStyle(.secondary)
                    Button("Dateien auswählen …") { openFilePicker() }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { openFilePicker() }
    }

    // MARK: - File List

    private var fileListView: some View {
        VStack(spacing: 0) {
            // List header
            HStack {
                Text("Warteschlange")
                    .font(.caption).fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase).tracking(0.5)
                Spacer()
                Button {
                    manager.clearAll()
                } label: {
                    Text("Alle entfernen")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .disabled(manager.isConverting)

                Button {
                    openFilePicker()
                } label: {
                    Image(systemName: "plus")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .disabled(manager.isConverting)
                .padding(.leading, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            List(selection: $selectedFile) {
                ForEach(manager.files) { file in
                    FileRowView(file: file, isCurrent: manager.currentIndex == manager.files.firstIndex(where: { $0.id == file.id }))
                        .tag(file)
                        .contextMenu {
                            if !manager.isConverting {
                                Button("Entfernen") { manager.remove(file) }
                                Button("Im Finder anzeigen") {
                                    NSWorkspace.shared.activateFileViewerSelecting([file.url])
                                }
                            }
                        }
                }
                .onDelete { offsets in
                    guard !manager.isConverting else { return }
                    for i in offsets { manager.remove(manager.files[i]) }
                }
            }
            .listStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Control bar

    private var controlBar: some View {
        HStack(spacing: 12) {
            // Settings summary chips
            HStack(spacing: 6) {
                Chip(label: settings.videoType.displayName.components(separatedBy: " ").first ?? "Film",
                     icon: "video")
                Chip(label: "Speed \(settings.speed)",
                     icon: "speedometer")
                if settings.dryRun {
                    Chip(label: "Trockenlauf", icon: "eye", tint: .orange)
                }
            }

            Spacer()

            // Stats after conversion
            if !manager.isConverting && manager.lastStats.filesCreated > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    Text("\(manager.lastStats.filesCreated) erstellt")
                        .font(.caption).foregroundStyle(.secondary)
                    if manager.lastStats.compressionPercent > 0 {
                        Text("· \(Int(manager.lastStats.compressionPercent))% gespart")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }

            if manager.isConverting {
                Button {
                    manager.cancelAll()
                } label: {
                    Label("Abbrechen", systemImage: "stop.fill")
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            } else {
                Button {
                    manager.startConversion(settings: settings)
                } label: {
                    Label(manager.files.isEmpty ? "Keine Dateien" : "Konvertieren",
                          systemImage: "play.fill")
                        .fontWeight(.semibold)
                        .frame(minWidth: 120)
                }
                .buttonStyle(.borderedProminent)
                .disabled(manager.files.isEmpty || ffmpegMissing)
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Log panel

    private var logPanel: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    if let file = selectedFile ?? manager.files.first {
                        ForEach(Array(file.logLines.enumerated()), id: \.offset) { idx, line in
                            Text(line)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(logLineColor(line))
                                .id(idx)
                        }
                    } else {
                        Text("Kein Log vorhanden.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 130)
            .background(Color(nsColor: .textBackgroundColor).opacity(0.5))
            .onChange(of: (selectedFile ?? manager.files.first)?.logLines.count ?? 0) { _ in
                let count = (selectedFile ?? manager.files.first)?.logLines.count ?? 0
                if count > 0 { proxy.scrollTo(count - 1, anchor: .bottom) }
            }
        }
    }

    // MARK: - File Operations

    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.mpeg4Movie, .quickTimeMovie,
                                     UTType(filenameExtension: "mp4") ?? .mpeg4Movie,
                                     UTType(filenameExtension: "mov") ?? .quickTimeMovie]
        panel.message = "MP4 oder MOV Videos auswählen"
        panel.prompt = "Hinzufügen"
        if panel.runModal() == .OK {
            manager.addFiles(panel.urls)
        }
    }

    private func logLineColor(_ line: String) -> Color {
        if line.hasPrefix("  ✗") { return .red }
        if line.hasPrefix("  ⚠") { return .orange }
        if line.hasPrefix("  ✓") { return .green }
        return .primary
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var handled = false
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(
                    forTypeIdentifier: UTType.fileURL.identifier, options: nil
                ) { item, _ in
                    let url: URL?
                    if let data = item as? Data {
                        url = URL(dataRepresentation: data, relativeTo: nil)
                    } else if let u = item as? URL {
                        url = u
                    } else {
                        url = nil
                    }
                    if let u = url, ["mp4", "mov"].contains(u.pathExtension.lowercased()) {
                        DispatchQueue.main.async { self.manager.addFiles([u]) }
                    }
                }
                handled = true
            }
        }
        return handled
    }
}

// MARK: - FileRowView

struct FileRowView: View {
    @ObservedObject var file: VideoFile
    var isCurrent: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Status icon
            statusIcon
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(file.filename)
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.middle)

                statusText
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Processing indicator
            if isCurrent, case .processing = file.status {
                ProgressView()
                    .scaleEffect(0.7)
                    .progressViewStyle(.circular)
            }
        }
        .padding(.vertical, 4)
        .listRowBackground(
            isCurrent ? Color.accentColor.opacity(0.08) : Color.clear
        )
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch file.status {
        case .pending:
            Image(systemName: "clock")
                .foregroundStyle(.secondary)
        case .processing:
            Image(systemName: "arrow.2.circlepath")
                .foregroundStyle(.blue)
        case .done(let stats):
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(stats.filesCreated > 0 ? .green : .orange)
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
        case .cancelled:
            Image(systemName: "minus.circle.fill")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var statusText: some View {
        switch file.status {
        case .pending:
            Text("Wartend")
        case .processing(let step):
            Text(step)
        case .done(let stats):
            let pct = stats.compressionPercent > 0 ? " · \(Int(stats.compressionPercent))% gespart" : ""
            Text("\(stats.filesCreated) Datei\(stats.filesCreated == 1 ? "" : "en") erstellt\(pct)")
        case .failed(let reason):
            Text("Fehler: \(reason)")
                .foregroundStyle(.red)
        case .cancelled:
            Text("Abgebrochen")
        }
    }
}

// MARK: - Chip helper

struct Chip: View {
    let label: String
    let icon: String
    var tint: Color = .secondary

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text(label).font(.caption)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 7).padding(.vertical, 3)
        .background(tint.opacity(0.1), in: Capsule())
    }
}
