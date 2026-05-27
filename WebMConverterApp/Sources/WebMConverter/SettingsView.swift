import SwiftUI
import AppKit

struct SettingsView: View {
    @EnvironmentObject var settings: ConversionSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Einstellungen")
                    .font(.title2).fontWeight(.semibold)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding([.horizontal, .top], 20)
            .padding(.bottom, 16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Video Type
                    SettingsSection(title: "Video-Typ") {
                        Picker("", selection: $settings.videoType) {
                            ForEach(VideoType.allCases) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        Text("CRF \(settings.videoType.baseCRF), Audio \(settings.videoType.audioBitrateKbps)k")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Speed
                    SettingsSection(title: "Encoding-Geschwindigkeit") {
                        HStack {
                            Text("Langsam").font(.caption).foregroundStyle(.secondary)
                            Slider(value: Binding(
                                get: { Double(settings.speed) },
                                set: { settings.speed = Int($0.rounded()) }
                            ), in: 0...5, step: 1)
                            Text("Schnell").font(.caption).foregroundStyle(.secondary)
                        }
                        Text("Wert: \(settings.speed)  (0 = beste Qualität, 5 = schnell)")
                            .font(.caption).foregroundStyle(.secondary)
                    }

                    // Variants (only without custom resolutions)
                    SettingsSection(title: "Varianten") {
                        ForEach(ConversionVariant.allCases) { variant in
                            let isDisabled = variant != .square && !settings.customResolutions.isEmpty
                            Toggle(isOn: Binding(
                                get: { settings.selectedVariants.contains(variant) },
                                set: { on in
                                    if on { settings.selectedVariants.insert(variant) }
                                    else  { settings.selectedVariants.remove(variant) }
                                }
                            )) {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(variant.displayName)
                                    Text(variant.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .disabled(isDisabled)
                            .opacity(isDisabled ? 0.4 : 1)
                        }
                    }

                    // Custom Resolutions
                    SettingsSection(title: "Auflösungen (optional)") {
                        TextField("z. B.  1920, 1280, 720", text: $settings.customResolutionsText)
                            .textFieldStyle(.roundedBorder)
                        VStack(alignment: .leading, spacing: 2) {
                            if settings.customResolutions.isEmpty {
                                Text("Standard: 1400, 1000, 500 px (Breitenangaben)")
                                    .font(.caption).foregroundStyle(.secondary)
                            } else {
                                Text("Aktiv: \(settings.customResolutions.map { "\($0)px" }.joined(separator: ", "))")
                                    .font(.caption).foregroundStyle(.tint)
                                Text("Bei custom Auflösungen entfallen Original- und 50%-Varianten.")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }

                    // Output Directory
                    SettingsSection(title: "Ausgabe-Ordner") {
                        HStack {
                            if let url = settings.customOutputURL {
                                Text(url.path)
                                    .lineLimit(1).truncationMode(.middle)
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Button("Entfernen") { settings.customOutputURL = nil }
                                    .font(.caption).foregroundStyle(.red)
                                    .buttonStyle(.plain)
                            } else {
                                Text("Neben der Quelldatei (output/)")
                                    .font(.caption).foregroundStyle(.secondary)
                                Spacer()
                                Button("Auswählen …") { chooseOutputDir() }
                                    .font(.caption)
                            }
                        }
                        .padding(8)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                    }

                    // Options
                    SettingsSection(title: "Optionen") {
                        Toggle("WebP Thumbnails erstellen", isOn: $settings.createThumbnail)
                        Toggle("Trockenlauf (kein Schreiben)", isOn: $settings.dryRun)
                    }

                }
                .padding(20)
            }

            Divider()

            HStack {
                Spacer()
                Button("Fertig") { dismiss() }
                    .keyboardShortcut(.return, modifiers: [])
                    .buttonStyle(.borderedProminent)
            }
            .padding(16)
        }
        .frame(width: 400, height: 620)
    }

    private func chooseOutputDir() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "Auswählen"
        if panel.runModal() == .OK {
            settings.customOutputURL = panel.url
        }
    }
}

// MARK: - SettingsSection helper

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            content()
        }
    }
}
