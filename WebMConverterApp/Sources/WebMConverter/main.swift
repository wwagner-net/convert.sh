import AppKit

// main.swift always runs on the main thread; tell the compiler explicitly.
MainActor.assumeIsolated {
    _ = NSApplication.shared
    NSApp.setActivationPolicy(.regular)
    let delegate = AppDelegate()
    NSApp.delegate = delegate
    NSApp.run()
}
