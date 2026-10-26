// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import UniformTypeIdentifiers

/// Saves every entry as a CSV file, the way to take them to a spreadsheet or
/// another Mac, since settings backups leave them out.
enum TimeTrackingExport {
    /// A modal panel: the menu bar panel already stays open while the tool
    /// shows, and the island holds open while a modal window is up. From the
    /// island the panel opens just above it, which floats over other windows.
    static func run(fromIsland: Bool) {
        guard !TimeTrackingService.shared.log.entries.isEmpty else { return }
        let language = L10n.shared.language
        let strings = FeatureStrings.timeTrackingExport(language)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.nameFieldStringValue = TimeTrackingCSV.fileName(title: FeatureStrings.timeTracking(language).title,
                                                              date: Date())
        if fromIsland, let island = NotchService.shared.presentationWindow {
            panel.level = NSWindow.Level(rawValue: island.level.rawValue + 1)
        }
        NSApp.activate(ignoringOtherApps: true)
        // Out of the button's action, so the click finishes before the modal loop.
        DispatchQueue.main.async {
            guard panel.runModal() == .OK, let url = panel.url else { return }
            // Read at the moment of saving: a running entry counts up to now.
            let csv = TimeTrackingCSV.make(TimeTrackingService.shared.log, header: strings.header, now: Date())
            do {
                try TimeTrackingCSV.data(csv).write(to: url, options: .atomic)
            } catch {
                QuickToolHUD.show(icon: "exclamationmark.triangle", message: strings.exportFailed)
            }
        }
    }
}
