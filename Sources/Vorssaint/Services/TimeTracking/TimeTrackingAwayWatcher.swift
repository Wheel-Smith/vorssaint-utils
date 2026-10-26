// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import Combine
import CoreGraphics

/// Notices time away from the Mac while an entry runs, so a forgotten timer
/// can be corrected: sleep, a locked screen, another user's session, and no
/// keyboard or mouse input for the cutoff. Nothing runs while no entry does;
/// while one runs, the idle reading is taken once a minute, and every few
/// seconds once idling, to catch the return promptly.
final class TimeTrackingAwayWatcher {
    static let shared = TimeTrackingAwayWatcher()

    private static let screenLockNotification = Notification.Name("com.apple.screenIsLocked")
    private static let screenUnlockNotification = Notification.Name("com.apple.screenIsUnlocked")

    /// Read from the session's event state, which needs no tap and no
    /// permission.
    private static let inputEventTypes: [CGEventType] = [
        .mouseMoved, .leftMouseDown, .rightMouseDown, .otherMouseDown, .leftMouseDragged,
        .scrollWheel, .keyDown, .flagsChanged,
    ]

    private var tracker = TimeTrackingAwayTracker()
    private var observers: [(NotificationCenter, NSObjectProtocol)] = []
    private var logSubscription: AnyCancellable?
    private var idleTimer: Timer?

    private init() {}

    /// Follows the feature's availability. Checked before touching the
    /// service, so uninstalling never loads the entries file.
    func sync() {
        guard AppFeature.timeTracking.isAvailable else {
            logSubscription = nil
            stopWatching()
            return
        }
        guard logSubscription == nil else { return }
        logSubscription = TimeTrackingService.shared.$log
            .map { $0.running?.id }
            .removeDuplicates()
            .sink { [weak self] runningID in
                if runningID == nil { self?.stopWatching() } else { self?.startWatching() }
            }
    }

    private func startWatching() {
        // A new entry starts its own count; nothing seen before belongs to it.
        tracker.reset()
        guard observers.isEmpty else {
            scheduleIdleCheck(after: 60)
            return
        }
        let workspace = NSWorkspace.shared.notificationCenter
        let distributed = DistributedNotificationCenter.default()
        observe(workspace, NSWorkspace.willSleepNotification) { $0.begin(.sleep) }
        observe(workspace, NSWorkspace.didWakeNotification) { $0.end(.sleep) }
        observe(workspace, NSWorkspace.sessionDidResignActiveNotification) { $0.begin(.switchedOut) }
        observe(workspace, NSWorkspace.sessionDidBecomeActiveNotification) { $0.end(.switchedOut) }
        observe(distributed, Self.screenLockNotification) { $0.begin(.lock) }
        observe(distributed, Self.screenUnlockNotification) { $0.end(.lock) }
        scheduleIdleCheck(after: 60)
    }

    private func stopWatching() {
        for (center, observer) in observers { center.removeObserver(observer) }
        observers = []
        idleTimer?.invalidate()
        idleTimer = nil
        tracker.reset()
    }

    private func observe(_ center: NotificationCenter, _ name: Notification.Name,
                         _ handle: @escaping (TimeTrackingAwayWatcher) -> Void) {
        let observer = center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            handle(self)
        }
        observers.append((center, observer))
    }

    private func begin(_ reason: TimeTrackingAwayTracker.Reason) {
        tracker.begin(reason, at: Date())
    }

    private func end(_ reason: TimeTrackingAwayTracker.Reason) {
        record(tracker.end(reason, at: Date()))
        // Timers do not fire during sleep; read idle afresh on the way back.
        scheduleIdleCheck(after: 5)
    }

    private func scheduleIdleCheck(after interval: TimeInterval) {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.checkIdle()
        }
        idleTimer?.tolerance = interval / 5
    }

    private func checkIdle() {
        let seconds = Self.inputEventTypes.map {
            CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: $0)
        }.min() ?? 0
        record(tracker.idle(seconds, at: Date(), cutoff: TimeTrackingLog.awayCutoff))
        scheduleIdleCheck(after: tracker.reasons.contains(.idle) ? 5 : 60)
    }

    private func record(_ stretch: TimeAway?) {
        guard let stretch else { return }
        TimeTrackingService.shared.noteAway(stretch)
    }
}
