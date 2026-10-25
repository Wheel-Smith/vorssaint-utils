// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Runs the latest time entry during the island timer's Pomodoro focus
/// phases and stops it for breaks, so a cycle is tracked without touching
/// the panel. The island re-subscribes whenever its settings change, so the
/// last state seen is kept here rather than in the subscription.
final class TimeTrackingPomodoroLink {
    static let shared = TimeTrackingPomodoroLink()

    private var wasFocusing: Bool?

    private init() {}

    static func isEnabled(in defaults: UserDefaults = .standard) -> Bool {
        AppFeature.timeTracking.isAvailable(in: defaults) && NotchTimerSupport.isEnabled(in: defaults)
            && defaults.bool(forKey: DefaultsKey.timeTrackingFollowsPomodoro)
    }

    /// Forgets the last session seen, so the next one is only recorded. A
    /// phase that ended while the link was off must not stop an entry
    /// started since.
    func reset() {
        wasFocusing = nil
    }

    func follow(_ session: NotchTimerSession) {
        let focusing = TimeTrackingPomodoroStep.focusing(session)
        defer { wasFocusing = focusing }
        guard Self.isEnabled() else { return }
        let tracking = TimeTrackingService.shared
        switch TimeTrackingPomodoroStep.step(wasFocusing: wasFocusing, isFocusing: focusing,
                                             entryRunning: tracking.running != nil) {
        case .resume:
            tracking.resumeLatest(fallback: FeatureStrings.notchActivities(L10n.shared.language).phase(.focus))
        case .stop:
            tracking.stop()
        case .none:
            break
        }
    }
}
