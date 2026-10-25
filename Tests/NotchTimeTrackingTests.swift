// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import Foundation

/// Time Tracking in Dynamic Island: its page, the running entry in the
/// closed island, and the link that lets Pomodoro focus phases run entries.
enum NotchTimeTrackingTests {
    static func run(_ suite: TestSuite) {
        gateContracts(suite)
        orderContracts(suite)
        readingContracts(suite)
        pomodoroContracts(suite)
        stringContracts(suite)
    }

    /// The page needs the feature; the strip needs the page and its own
    /// switch, which is on by default and travels in settings backup.
    private static func gateContracts(_ suite: TestSuite) {
        let domain = "vorss.tests.notch-time-tracking"
        let defaults = UserDefaults(suiteName: domain)!
        defaults.removePersistentDomain(forName: domain)
        defer { defaults.removePersistentDomain(forName: domain) }
        for (key, value) in Defaults.registeredDefaults where key.hasPrefix("notch") || key.hasPrefix("timeTracking") {
            defaults.set(value, forKey: key)
        }
        for (key, value) in AppFeature.availabilityDefaults { defaults.set(value, forKey: key) }
        defaults.set(true, forKey: DefaultsKey.notchEnabled)
        suite.expect(!NotchSupport.modules(in: defaults).contains(.timeTracking)
                     && !NotchTimeTrackingSupport.showsActivity(in: defaults),
                     "the island has no Time Tracking page or strip until the feature is installed")
        defaults.set(true, forKey: AppFeature.timeTracking.availabilityKey)
        suite.expect(NotchSupport.modules(in: defaults).last == .timeTracking
                     && NotchTimeTrackingSupport.showsActivity(in: defaults),
                     "installing it adds the page at the end and shows a running entry by default")
        defaults.set(false, forKey: DefaultsKey.notchTimeTrackingActivity)
        suite.expect(NotchSupport.modules(in: defaults).contains(.timeTracking)
                     && !NotchTimeTrackingSupport.showsActivity(in: defaults),
                     "the strip follows its own switch and keeps the page")
        defaults.set(true, forKey: DefaultsKey.notchTimeTrackingActivity)
        defaults.set("timeTracking", forKey: DefaultsKey.notchHiddenModules)
        suite.expect(!NotchTimeTrackingSupport.showsActivity(in: defaults),
                     "a hidden page takes the strip that would open it")
        defaults.set("", forKey: DefaultsKey.notchHiddenModules)
        defaults.set(false, forKey: DefaultsKey.notchEnabled)
        suite.expect(!NotchTimeTrackingSupport.showsActivity(in: defaults), "the island's master switch gates it too")
        suite.expect(SettingsBackupSupport.exportKeys().isSuperset(of: [DefaultsKey.notchTimeTrackingActivity,
                                                                        DefaultsKey.timeTrackingFollowsPomodoro]),
                     "both switches travel in settings backup")
        suite.expect(NotchCompactActivity.timeTracking.module == .timeTracking
                     && NotchCompactActivity.timeTracking.symbol == NotchTimeTrackingSupport.symbol
                     && NotchModule.timeTracking.symbol == AppFeature.timeTracking.symbolName,
                     "the strip opens its page and the picker shows the strip's clock")
    }

    /// A running entry waits behind everything that ends sooner, and only
    /// Keep Awake waits behind it.
    private static func orderContracts(_ suite: TestSuite) {
        suite.expect(NotchSupport.compactActivity(timer: false, downloads: false, music: true, timeTracking: true) == .music
                     && NotchSupport.compactActivity(timer: true, downloads: false, music: false, timeTracking: true) == .timer
                     && NotchSupport.compactActivity(timer: false, downloads: true, music: false, timeTracking: true)
                         == .downloads
                     && NotchSupport.compactActivity(timer: false, downloads: false, calendar: true, music: false,
                                                     timeTracking: true) == .calendar,
                     "timers, downloads, events and music all come before a running entry")
        suite.expect(NotchSupport.compactActivity(timer: false, downloads: false, music: false, timeTracking: true,
                                                  keepAwake: true) == .timeTracking
                     && NotchSupport.compactActivities(timer: false, downloads: false, agents: false, calendar: false,
                                                       music: false, timeTracking: true, keepAwake: true)
                         == [.timeTracking, .keepAwake],
                     "a running entry comes before Keep Awake, and the picker still offers both")
        for primary in [NotchCompactActivity.timer, .calendar] {
            suite.expect(!NotchSupport.compactCompanions(of: primary, timer: true, running: true, downloads: true,
                                                         agents: true, calendar: true, music: true)
                            .contains(.timeTracking),
                         "a running entry never shares a strip as a companion")
        }
    }

    /// The menu bar item's reading, a clock that wakes once a minute, and
    /// wings wide enough for both sides.
    private static func readingContracts(_ suite: TestSuite) {
        let start = Date(timeIntervalSinceReferenceDate: 800_000_000)
        func text(_ seconds: TimeInterval) -> String {
            NotchTimeTrackingSupport.compactText(since: start, now: start.addingTimeInterval(seconds))
        }
        suite.expect(text(0) == "0:00" && text(1) == "0:01" && text(60) == "0:01" && text(61) == "0:02"
                     && text(42 * 60 + 30) == "0:43" && text(12 * 3600 + 5 * 60) == "12:05",
                     "the strip rounds a started minute up, as the menu bar item does")
        suite.expect(text(-90) == "0:00", "a clock set back while the entry runs never reads negative time")
        for seconds: TimeInterval in [0, 1, 59.5, 60, 61, 3599.5, 3600, 36_000] {
            let now = start.addingTimeInterval(seconds)
            let tick = NotchTimeTrackingSupport.tickStart(since: start, now: now)
            let next = tick.addingTimeInterval(60)
            // The reading changes just after each boundary; the clock wakes
            // half a second later and stays right until its next tick.
            suite.expect(tick <= now && next > now
                         && NotchTimeTrackingSupport.compactText(since: start, now: next)
                            != NotchTimeTrackingSupport.compactText(since: start, now: next.addingTimeInterval(-1))
                         && NotchTimeTrackingSupport.compactText(since: start, now: next)
                            == NotchTimeTrackingSupport.compactText(since: start, now: next.addingTimeInterval(59)),
                         "the minute clock wakes just after the reading changes, \(seconds) seconds in")
        }
        let screen = CGRect(x: 0, y: 0, width: 1512, height: 982)
        for barHeight: CGFloat in [22, 24, 32, 40] {
            for notched in [false, true] {
                let original = NotchGeometry(screen: screen, safeAreaTop: notched ? 32 : 0,
                                             cameraWidth: notched ? 180 : 0, menuBarHeight: barHeight,
                                             compactSideRoom: 200)
                var widths: [CGFloat] = []
                for elapsed: TimeInterval in [0, 42 * 60, 10 * 3600, 100 * 3600] {
                    let wing = NotchTimeTrackingSupport.stripWing(start: start, now: start.addingTimeInterval(elapsed),
                                                                  in: original)
                    widths.append(wing)
                    let compact = original.compactTimerGeometry(showsDownloads: false, wing: wing)
                    suite.expect(!compact.compactActivityUsesFooter
                                 && compact.compactActivityWingWidth >= min(wing, NotchTimerSupport.stripWingRange.upperBound)
                                 && compact.compactActivityWingWidth >= 42,
                                 "the clock and the time so far keep readable wings beside the camera")
                }
                suite.expect(widths == widths.sorted()
                             && NotchTimeTrackingSupport.stripWing(start: nil, now: start, in: original) == widths[0],
                             "the wings only grow as the reading gains digits, and no entry measures a fresh one")
            }
        }
        let geometry = NotchGeometry(screen: CGRect(x: 0, y: 0, width: 1512, height: 982), safeAreaTop: 0, cameraWidth: 0)
        suite.expect(NotchCapsuleLayout.timeTrackingSurface(reading: "0:42", geometry: geometry)
                        == NotchCapsuleLayout.timeTrackingSurface(reading: "8:15", geometry: geometry)
                     && NotchCapsuleLayout.timeTrackingSurface(reading: "100:00", geometry: geometry).width
                        >= NotchCapsuleLayout.timeTrackingSurface(reading: "9:59", geometry: geometry).width,
                     "the capsule only moves when the reading gains a character")
    }

    /// Focus phases run the latest entry and breaks stop it; only changes
    /// act, so what the person does in the middle of a phase stays.
    private static func pomodoroContracts(_ suite: TestSuite) {
        typealias Step = TimeTrackingPomodoroStep
        suite.expect(Step.step(wasFocusing: nil, isFocusing: true, entryRunning: false) == .none
                     && Step.step(wasFocusing: nil, isFocusing: false, entryRunning: true) == .none,
                     "the first session seen is only recorded, so a relaunch neither starts nor stops an entry")
        suite.expect(Step.step(wasFocusing: false, isFocusing: true, entryRunning: false) == .resume
                     && Step.step(wasFocusing: false, isFocusing: true, entryRunning: true) == .none,
                     "a focus phase starts the latest entry again, and leaves one that already runs")
        suite.expect(Step.step(wasFocusing: true, isFocusing: false, entryRunning: true) == .stop
                     && Step.step(wasFocusing: true, isFocusing: false, entryRunning: false) == .none,
                     "leaving a focus phase stops the running entry")
        suite.expect(Step.step(wasFocusing: true, isFocusing: true, entryRunning: false) == .none
                     && Step.step(wasFocusing: false, isFocusing: false, entryRunning: true) == .none,
                     "an entry stopped or started by hand mid-phase is left alone")

        let configuration = NotchPomodoroConfiguration()
        var session = NotchTimerSession()
        suite.expect(!Step.focusing(session), "no session is not focus")
        session.start(mode: .pomodoro, minutes: 25, now: 0, configuration: configuration)
        suite.expect(Step.focusing(session), "a Pomodoro starts in a running focus phase")
        session.pause(at: 10)
        suite.expect(!Step.focusing(session), "a paused focus phase is not tracked")
        session.resume(at: 20)
        suite.expect(Step.focusing(session), "resuming tracks again")
        session.finishIfDue(at: 1_000_000)
        suite.expect(!Step.focusing(session), "a finished focus phase stops tracking before the break starts")
        session.startNext(at: 1_000_001)
        suite.expect(session.phase != .focus && !Step.focusing(session), "a break is not tracked")
        var stopwatch = NotchTimerSession()
        stopwatch.start(mode: .stopwatch, minutes: 0, now: 0)
        var timer = NotchTimerSession()
        timer.start(mode: .timer, minutes: 5, now: 0)
        suite.expect(!Step.focusing(stopwatch) && !Step.focusing(timer), "only Pomodoro focus phases run entries")

        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)
        var empty = TimeTrackingLog()
        empty.resumeLatest(at: now, fallback: "Focus")
        suite.expect(empty.running?.description == "Focus",
                     "with nothing to continue, a focus phase starts an entry named after it")
        var log = TimeTrackingLog()
        log.start(description: "Island", at: now.addingTimeInterval(-3600))
        log.stop(at: now.addingTimeInterval(-1800))
        let resumed = log.resumeLatest(at: now, fallback: "Focus")
        suite.expect(resumed != nil && log.running?.id == resumed && log.running?.description == "Island"
                     && log.entries.count == 2,
                     "a focus phase continues the latest entry, as a new entry")
        let running = log
        suite.expect(log.resumeLatest(at: now.addingTimeInterval(60), fallback: "Focus") == nil && log == running,
                     "an entry that already runs is never replaced")
    }

    private static func stringContracts(_ suite: TestSuite) {
        for language in AppLanguage.allCases {
            let island = FeatureStrings.timeTrackingIsland(language)
            let texts = [island.activity, island.activityHint, island.followsPomodoro, island.followsPomodoroHint,
                         FeatureStrings.notchEditor(language).summary(.timeTracking)]
            suite.expect(texts.allSatisfy { !$0.isEmpty && !$0.contains("—") && !$0.contains("...") },
                         "Time Tracking's island text is written out in \(language.rawValue)")
            if language != .enUS {
                suite.expect(island.activity != TimeTrackingIslandStrings.enUS.activity
                             && island.followsPomodoroHint != TimeTrackingIslandStrings.enUS.followsPomodoroHint,
                             "Time Tracking's island text is translated in \(language.rawValue)")
            }
        }
    }
}
