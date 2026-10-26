// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import Combine

/// Starts and stops time entries from outside the panel: the global shortcut
/// and the Command Bar. Each change shows a short notice, since neither place
/// shows the entry itself. Kept apart from `TimeTrackingService` so syncing
/// the shortcut, which also runs when the feature is uninstalled, never loads
/// the entries file.
final class TimeTrackingCommands: ObservableObject {
    static let shared = TimeTrackingCommands()

    @Published private(set) var shortcutRegistrationFailed = false

    private let hotkey = QuickToolHotkey(id: 62)

    private init() {
        hotkey.onPress = { [weak self] in self?.toggle() }
    }

    func syncWithPreferences() {
        let enabled = AppFeature.timeTracking.isAvailable
            && UserDefaults.standard.bool(forKey: DefaultsKey.timeTrackingShortcutEnabled)
        let shortcut = GlobalShortcut.saved(for: DefaultsKey.timeTrackingShortcut,
                                            fallback: .timeTrackingDefault)
        shortcutRegistrationFailed = !hotkey.sync(enabled: enabled, shortcut: shortcut,
                                                  storageKey: DefaultsKey.timeTrackingShortcut)
    }

    func suspend() {
        hotkey.unregister()
    }

    /// The shortcut: stops the running entry, or continues the latest one so
    /// a single key picks work back up. With no entries yet it starts an
    /// untitled one.
    func toggle() {
        let tracking = TimeTrackingService.shared
        if tracking.running != nil {
            stop()
        } else if let latest = tracking.log.recent(limit: 1).first {
            continueEntry(latest.id)
        } else {
            start(description: "")
        }
    }

    func start(description: String) {
        guard AppFeature.timeTracking.isAvailable else { return }
        TimeTrackingService.shared.start(description: description)
        announceStart()
    }

    func continueEntry(_ id: UUID) {
        guard AppFeature.timeTracking.isAvailable else { return }
        TimeTrackingService.shared.continueEntry(id)
        announceStart()
    }

    func stop() {
        let tracking = TimeTrackingService.shared
        guard AppFeature.timeTracking.isAvailable, let running = tracking.running else { return }
        tracking.stop()
        // An unreadable entries file refuses every change; saying "stopped"
        // then would be a lie.
        guard tracking.running == nil else {
            NSSound.beep()
            return
        }
        let strings = FeatureStrings.timeTrackingCommands(L10n.shared.language)
        QuickToolHUD.show(icon: AppFeature.timeTracking.symbolName,
                          message: String(format: strings.stoppedFormat, name(of: running)))
    }

    private func announceStart() {
        guard let running = TimeTrackingService.shared.running else {
            NSSound.beep()
            return
        }
        let strings = FeatureStrings.timeTrackingCommands(L10n.shared.language)
        QuickToolHUD.show(icon: AppFeature.timeTracking.symbolName,
                          message: String(format: strings.startedFormat, name(of: running)))
    }

    func name(of entry: TimeEntry) -> String {
        entry.description.isEmpty
            ? FeatureStrings.timeTracking(L10n.shared.language).untitled
            : entry.description
    }
}
