// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit

/// A running time entry as a live activity of the closed island: its clock
/// left of the camera, and the time it has run so far on the right, as the
/// menu bar item reads it.
enum NotchTimeTrackingSupport {
    /// A clock rather than the feature's stopwatch, which the island's own
    /// timer already shows in its stopwatch mode.
    static let symbol = "clock.fill"

    /// On by default: an entry only runs when the person starts one, and the
    /// strip waits behind every activity that ends sooner.
    static func showsActivity(in defaults: UserDefaults = .standard) -> Bool {
        NotchSupport.isEnabled(in: defaults) && AppFeature.timeTracking.isAvailable(in: defaults)
            && defaults.bool(forKey: DefaultsKey.notchTimeTrackingActivity)
            && NotchSupport.modules(in: defaults).contains(.timeTracking)
    }

    /// "0:42", "12:05": the menu bar item's reading, in whole minutes.
    static func compactText(since start: Date, now: Date) -> String {
        TimeTrackingFormat.clock(now.timeIntervalSince(start))
    }

    /// The minute boundary the reading last crossed. A schedule that ticks
    /// once a minute from there wakes exactly when the reading changes.
    static func tickStart(since start: Date, now: Date) -> Date {
        TimeTrackingFormat.nextMinuteBoundary(after: now, start: start).addingTimeInterval(-60)
    }

    /// The wider of the two sides, the clock or the reading, drawn as the
    /// strip draws them, with the timer's clearance from the silhouette's
    /// curve and air beside the camera. No entry measures a fresh one.
    static func stripWing(start: Date?, now: Date, in geometry: NotchGeometry) -> CGFloat {
        let provisional = geometry.compactTimerGeometry(showsDownloads: false,
                                                        wing: NotchTimerSupport.stripWingRange.lowerBound)
        let height = provisional.compactActivityContentHeight
        let textSize = NotchTimerSupport.stripTextSize(height: height)
        let text = compactText(since: start ?? now, now: now)
        let reading = (NotchAgentSupport.readingShape(text) as NSString)
            .size(withAttributes: [.font: NSFont.monospacedDigitSystemFont(ofSize: textSize, weight: .medium)])
            .width.rounded(.up)
        let iconSize = NotchTimerSupport.stripIconSize(height: height)
        let mark = NotchKeepAwakeSupport.symbolWidth(symbol, size: iconSize)
            + provisional.compactActivityEdgeInset(boxHeight: iconSize, radius: iconSize / 2)
        return max(reading + provisional.compactActivityEdgeInset(boxHeight: textSize * 0.72, radius: 0), mark)
            + NotchTimerSupport.stripCameraGap
    }
}

/// What the Pomodoro link does when the island's timer changes: a focus
/// phase that starts or resumes runs an entry, and one that ends, pauses or
/// is cancelled stops whatever entry runs. Only changes act, so stopping or
/// starting an entry by hand in the middle of a phase is not undone.
enum TimeTrackingPomodoroStep: Equatable {
    case none, resume, stop

    static func focusing(_ session: NotchTimerSession) -> Bool {
        session.mode == .pomodoro && session.phase == .focus && session.isRunning
    }

    /// `wasFocusing` is nil the first time the link sees a session, which
    /// only records it: a relaunch must not start or stop anything.
    static func step(wasFocusing: Bool?, isFocusing: Bool, entryRunning: Bool) -> Self {
        guard let wasFocusing, wasFocusing != isFocusing else { return .none }
        if isFocusing { return entryRunning ? .none : .resume }
        return entryRunning ? .stop : .none
    }
}

extension TimeTrackingLog {
    /// Continues the most recent entry, or starts one named `fallback` when
    /// there is none to continue. Nothing changes while an entry runs.
    @discardableResult
    mutating func resumeLatest(at now: Date, fallback: String, newID: UUID = UUID()) -> UUID? {
        guard running == nil else { return nil }
        if let latest = entries.last { return continueEntry(latest.id, at: now, newID: newID) }
        return start(description: fallback, at: now, id: newID)
    }
}
