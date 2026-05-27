import AppKit
import SwiftUI

// Posted by the menu → picked up by ContentView to open the settings sheet
extension Notification.Name {
    static let openSettings = Notification.Name("WebMConverter.openSettings")
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let manager  = ConversionManager()
    let settings = ConversionSettings()

    // MARK: - Launch

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()

        let content = ContentView()
            .environmentObject(manager)
            .environmentObject(settings)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 820, height: 620),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "WebM Converter"
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.contentView = NSHostingView(rootView: content)
        window.center()
        window.setFrameAutosaveName("MainWindow")
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        manager.cancelAll()
        return true
    }

    // MARK: - Menu bar

    private func setupMenuBar() {
        let mainMenu = NSMenu()

        // ── App menu ──────────────────────────────────────────────────────
        let appItem = NSMenuItem()
        mainMenu.addItem(appItem)
        let appMenu = NSMenu()
        appItem.submenu = appMenu

        appMenu.addItem(
            withTitle: "Über WebM Converter",
            action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
            keyEquivalent: "")

        appMenu.addItem(.separator())

        let prefsItem = NSMenuItem(
            title: "Einstellungen…",
            action: #selector(openPreferences(_:)),
            keyEquivalent: ",")
        prefsItem.keyEquivalentModifierMask = .command
        appMenu.addItem(prefsItem)

        appMenu.addItem(.separator())

        appMenu.addItem(
            withTitle: "WebM Converter ausblenden",
            action: #selector(NSApplication.hide(_:)),
            keyEquivalent: "h")

        let hideOthers = NSMenuItem(
            title: "Andere ausblenden",
            action: #selector(NSApplication.hideOtherApplications(_:)),
            keyEquivalent: "h")
        hideOthers.keyEquivalentModifierMask = [.command, .option]
        appMenu.addItem(hideOthers)

        appMenu.addItem(
            withTitle: "Alle einblenden",
            action: #selector(NSApplication.unhideAllApplications(_:)),
            keyEquivalent: "")

        appMenu.addItem(.separator())

        appMenu.addItem(
            withTitle: "WebM Converter beenden",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q")

        // ── File menu ─────────────────────────────────────────────────────
        let fileItem = NSMenuItem()
        mainMenu.addItem(fileItem)
        let fileMenu = NSMenu(title: "Ablage")
        fileItem.submenu = fileMenu

        fileMenu.addItem(
            withTitle: "Dateien öffnen…",
            action: #selector(openFiles(_:)),
            keyEquivalent: "o")

        // ── Window menu ───────────────────────────────────────────────────
        let windowItem = NSMenuItem()
        mainMenu.addItem(windowItem)
        let windowMenu = NSMenu(title: "Fenster")
        windowItem.submenu = windowMenu

        windowMenu.addItem(
            withTitle: "Minimieren",
            action: #selector(NSWindow.miniaturize(_:)),
            keyEquivalent: "m")
        windowMenu.addItem(
            withTitle: "Zoomen",
            action: #selector(NSWindow.zoom(_:)),
            keyEquivalent: "")
        windowMenu.addItem(.separator())
        windowMenu.addItem(
            withTitle: "In Vordergrund bringen",
            action: #selector(NSApplication.arrangeInFront(_:)),
            keyEquivalent: "")

        NSApp.mainMenu   = mainMenu
        NSApp.windowsMenu = windowMenu
    }

    // MARK: - Menu actions

    @objc private func openPreferences(_ sender: Any?) {
        // ContentView listens for this notification to open the settings sheet
        NotificationCenter.default.post(name: .openSettings, object: nil)
    }

    @objc private func openFiles(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.canChooseFiles        = true
        panel.canChooseDirectories  = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes   = [.mpeg4Movie, .quickTimeMovie]
        panel.message  = "MP4 oder MOV Videos auswählen"
        panel.prompt   = "Hinzufügen"
        guard panel.runModal() == .OK else { return }
        manager.addFiles(panel.urls)
        window.makeKeyAndOrderFront(nil)
    }
}
