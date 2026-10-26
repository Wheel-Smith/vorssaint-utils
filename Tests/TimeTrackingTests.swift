// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

enum TimeTrackingTests {
    static func run(_ suite: TestSuite) {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        let parser = ISO8601DateFormatter()
        func date(_ text: String) -> Date { parser.date(from: text)! }

        // MARK: One entry at a time

        var log = TimeTrackingLog()
        let first = log.start(description: "Write docs", at: date("2026-10-20T09:00:00Z"))
        let second = log.start(description: "Review", at: date("2026-10-20T09:30:00Z"))
        suite.expect(log.entries.filter(\.isRunning).map(\.id) == [second],
                     "starting an entry stops the running one, so only one runs")
        suite.expect(log.entries.first { $0.id == first }?.end == date("2026-10-20T09:30:00Z"),
                     "the stopped entry ends exactly when the next one starts")

        var backwards = TimeTrackingLog()
        backwards.start(description: "Clock moved", at: date("2026-10-20T10:00:00Z"))
        backwards.stop(at: date("2026-10-20T09:50:00Z"))
        suite.expect(backwards.entries.first?.end == date("2026-10-20T10:00:00Z")
                         && backwards.entries.first?.duration(at: date("2026-10-20T11:00:00Z")) == 0,
                     "a clock set back while an entry ran never produces negative time")

        var continued = TimeTrackingLog()
        let original = continued.start(description: "Fix bug", at: date("2026-10-20T08:00:00Z"))
        continued.stop(at: date("2026-10-20T08:20:00Z"))
        continued.continueEntry(original, at: date("2026-10-20T08:40:00Z"))
        suite.expect(continued.running?.description == "Fix bug" && continued.running?.id != original,
                     "continuing starts a new entry with the same description")

        var cleaned = TimeTrackingLog()
        cleaned.start(description: "  Line one\nline two  ", at: date("2026-10-20T08:00:00Z"))
        suite.expect(cleaned.running?.description == "Line one line two",
                     "descriptions are kept on one line without surrounding spaces")

        // MARK: Reports

        var report = TimeTrackingLog()
        // Ran over midnight into the 20th: only 30 minutes belong to today.
        report.start(description: "Work", at: date("2026-10-19T23:30:00Z"))
        report.stop(at: date("2026-10-20T00:30:00Z"))
        // Five days earlier and untitled: inside 7 days, outside today.
        report.start(description: "", at: date("2026-10-15T10:00:00Z"))
        report.stop(at: date("2026-10-15T11:30:00Z"))
        // Forty days earlier: outside 30 days.
        report.start(description: "Work", at: date("2026-09-10T10:00:00Z"))
        report.stop(at: date("2026-09-10T11:00:00Z"))
        // Still running at noon, spelled differently: the same work.
        report.start(description: "work", at: date("2026-10-20T11:00:00Z"))
        let noon = date("2026-10-20T12:00:00Z")

        let today = report.totals(for: .today, now: noon, calendar: utc)
        suite.expect(today == [TimeEntryTotal(description: "work", seconds: 5400)],
                     "today counts only the part after midnight plus the running entry up to now")
        let week = report.totals(for: .week, now: noon, calendar: utc)
        suite.expect(week == [TimeEntryTotal(description: "work", seconds: 7200),
                              TimeEntryTotal(description: "", seconds: 5400)],
                     "totals group descriptions ignoring case, keep untitled time and sort by time")
        suite.expect(report.total(for: .month, now: noon, calendar: utc) == 12600,
                     "30 days leaves out entries older than thirty days")
        suite.expect(TimeTrackingLog.periodStart(.week, now: noon, calendar: utc) == date("2026-10-14T00:00:00Z"),
                     "7 days starts at midnight six days before today, as in the AI agents view")

        var recent = TimeTrackingLog()
        recent.start(description: "A", at: date("2026-10-20T08:00:00Z"))
        recent.start(description: "B", at: date("2026-10-20T08:10:00Z"))
        recent.start(description: "a", at: date("2026-10-20T08:20:00Z"))
        recent.start(description: "C", at: date("2026-10-20T08:30:00Z"))
        suite.expect(recent.recent(limit: 5).map(\.description) == ["a", "B"],
                     "recent entries are newest first, one per description, never the running one")
        recent.rename(recent.recent(limit: 5)[0].id, to: "Alpha")
        suite.expect(recent.entries.map(\.description) == ["Alpha", "B", "Alpha", "C"],
                     "renaming a recent entry renames every entry with that description, ignoring case")

        // MARK: Repairing a damaged file

        let runningOld = TimeEntry(id: UUID(), description: "Old run",
                                   start: date("2026-10-20T08:00:00Z"), end: nil)
        let runningNew = TimeEntry(id: UUID(), description: "New run",
                                   start: date("2026-10-20T09:00:00Z"), end: nil)
        let inverted = TimeEntry(id: UUID(), description: "Inverted",
                                 start: date("2026-10-20T10:00:00Z"), end: date("2026-10-20T09:00:00Z"))
        let early = TimeEntry(id: UUID(), description: "Early",
                              start: date("2026-10-20T07:00:00Z"), end: date("2026-10-20T07:30:00Z"))
        let repaired = TimeTrackingLog(entries: [runningNew, inverted, runningOld, early, early]).sanitized()
        suite.expect(repaired.entries.map(\.description) == ["Early", "Old run", "New run"],
                     "repair drops duplicates and entries that end before they start, oldest first")
        suite.expect(repaired.entries.filter(\.isRunning).map(\.id) == [runningNew.id],
                     "repair leaves only the latest of several running entries running")

        // MARK: Store

        let manager = FileManager.default
        func withDirectory(_ body: (URL) -> Void) {
            let directory = manager.temporaryDirectory
                .appendingPathComponent("vorss-time-tracking-\(UUID().uuidString)", isDirectory: true)
            defer { try? manager.removeItem(at: directory) }
            body(directory)
        }

        withDirectory { directory in
            var store = TimeTrackingStore(directoryURL: directory)
            let empty = try? store.load()
            suite.expect(empty == TimeTrackingLog(), "no file yet loads as an empty log")
            var saved = TimeTrackingLog()
            saved.start(description: "Persist", at: date("2026-10-20T08:00:00Z"))
            suite.expect(store.save(saved), "a log saves once the file was read")
            var reopened = TimeTrackingStore(directoryURL: directory)
            let loaded = try? reopened.load()
            suite.expect(loaded == saved, "a saved log reads back unchanged, running entry included")
            let path = directory.appendingPathComponent(TimeTrackingStore.fileName).path
            let mode = (try? manager.attributesOfItem(atPath: path))?[.posixPermissions] as? Int
            suite.expect(mode == 0o600, "the log file is readable only by its owner")
        }

        withDirectory { directory in
            _ = PrivateFileStore.createDirectory(at: directory, container: directory)
            let url = directory.appendingPathComponent(TimeTrackingStore.fileName)
            // A field this version does not know, as another version might write.
            let draft = #"{"entries":[{"description":"Call","end":"2026-10-20T09:00:00Z","#
                + #""id":"\#(UUID().uuidString)","projectID":"\#(UUID().uuidString)","#
                + #""start":"2026-10-20T08:00:00Z"}],"projects":[]}"#
            try? Data(draft.utf8).write(to: url)
            var store = TimeTrackingStore(directoryURL: directory)
            let loaded = try? store.load()
            suite.expect(loaded?.entries.map(\.description) == ["Call"]
                             && loaded?.entries.first?.duration(at: Date()) == 3600,
                         "a file with fields this version does not know still loads every entry")
        }

        withDirectory { directory in
            _ = PrivateFileStore.createDirectory(at: directory, container: directory)
            let url = directory.appendingPathComponent(TimeTrackingStore.fileName)
            let garbage = Data("{ not json".utf8)
            try? garbage.write(to: url)
            var store = TimeTrackingStore(directoryURL: directory)
            let failed = (try? store.load()) == nil
            suite.expect(failed, "an unreadable file fails to load instead of reading as empty")
            suite.expect(!store.save(TimeTrackingLog()) && (try? Data(contentsOf: url)) == garbage,
                         "a failed read never lets a save replace the file")
        }

        // MARK: Formatting

        suite.expect(TimeTrackingFormat.clock(0) == "0:00" && TimeTrackingFormat.clock(1) == "0:01"
                         && TimeTrackingFormat.clock(60) == "0:01" && TimeTrackingFormat.clock(8 * 60 + 30) == "0:09"
                         && TimeTrackingFormat.clock(12 * 3600 + 5 * 60) == "12:05"
                         && TimeTrackingFormat.clock(-30) == "0:00",
                     "the clock rounds a started minute up, shows hours and minutes and never goes negative")
        let started = date("2026-10-20T08:00:30Z")
        suite.expect(TimeTrackingFormat.nextMinuteBoundary(after: date("2026-10-20T08:02:00Z"), start: started)
                         == date("2026-10-20T08:02:30Z").addingTimeInterval(0.5)
                         && TimeTrackingFormat.nextMinuteBoundary(after: started, start: started)
                         == started.addingTimeInterval(0.5),
                     "the menu bar timer wakes just after the entry's next minute boundary, at once for a new entry")

        // MARK: Strings and defaults

        for language in AppLanguage.allCases {
            let strings = FeatureStrings.timeTracking(language)
            let values = Mirror(reflecting: strings).children.compactMap { $0.value as? String }
            suite.expect(values.allSatisfy { !$0.isEmpty && !$0.contains("\u{2014}") && !$0.contains("...") },
                         "time tracking strings are complete, without em dashes or three periods (\(language.rawValue))")
            if language != .enUS {
                suite.expect(strings.title != TimeTrackingFeatureStrings.enUS.title,
                             "the feature name is translated (\(language.rawValue))")
            }
        }
        suite.expect(Defaults.registeredDefaults[DefaultsKey.panelUtilityTimeTracking] as? Bool == true
                         && Defaults.registeredDefaults[DefaultsKey.timeTrackingMenuBarTimer] as? Bool == true,
                     "the panel tile and the menu bar timer start visible once the feature is installed")
        suite.expect(AppFeature.timeTracking.group == .tools && AppFeature.timeTracking.permissions.isEmpty
                         && !AppFeature.timeTracking.installedByDefault,
                     "time tracking is an opt-in tool that needs no permission")

        // MARK: Time away

        let nine = date("2026-10-20T09:00:00Z")
        func at(_ minutes: Double) -> Date { nine.addingTimeInterval(minutes * 60) }
        var away = TimeTrackingLog()
        let awayID = away.start(description: "Docs", at: nine)
        away.noteAway(from: at(10), to: at(14))
        suite.expect(away.away.isEmpty, "a stretch under five minutes is not time away")
        away.noteAway(from: at(-30), to: at(20))
        suite.expect(away.away == [TimeAway(start: nine, end: at(20))],
                     "only the part after the entry started counts as away")
        away.noteAway(from: at(18), to: at(30))
        away.noteAway(from: at(60), to: at(70))
        suite.expect(away.away == [TimeAway(start: nine, end: at(30)), TimeAway(start: at(60), end: at(70))]
                         && away.awayDuration == 40 * 60,
                     "overlapping stretches join, separate ones stay apart")

        var kept = away
        kept.keepAway()
        suite.expect(kept.away.isEmpty && kept.entries == away.entries,
                     "keeping the time away leaves the entry untouched")

        var discarded = away
        var newIDs = [UUID(), UUID()]
        discarded.discardAway(stopping: false, newID: { newIDs.removeFirst() })
        suite.expect(discarded.away.isEmpty
                         && discarded.entries.map(\.start) == [at(30), at(70)]
                         && discarded.entries.map(\.end) == [at(60), nil]
                         && discarded.entries.allSatisfy { $0.description == "Docs" },
                     "discarding cuts the entry at each stretch and keeps it running after the last")
        suite.expect(discarded.entries.first?.id == awayID,
                     "the first piece keeps the entry's own id")

        var discardedAndStopped = away
        discardedAndStopped.discardAway(stopping: true)
        suite.expect(discardedAndStopped.running == nil
                         && discardedAndStopped.entries.map(\.end) == [at(60)],
                     "discard and stop ends the entry where the last stretch began")

        var stoppedAway = away
        stoppedAway.stop(at: at(80))
        suite.expect(stoppedAway.away.isEmpty && stoppedAway.entries.first?.end == at(80),
                     "stopping keeps the time away")
        var deletedAway = away
        deletedAway.delete(awayID)
        suite.expect(deletedAway.away.isEmpty, "deleting the running entry drops its time away")

        let oldFile = Data(#"{"entries":[{"id":"\#(UUID().uuidString)","description":"Old","start":"2026-10-20T09:00:00Z"}]}"#.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedOld = try? decoder.decode(TimeTrackingLog.self, from: oldFile)
        suite.expect(decodedOld?.running?.description == "Old" && decodedOld?.away.isEmpty == true,
                     "a file written before time away was kept still loads")
        var handEdited = away
        handEdited.away.append(TimeAway(start: at(90), end: at(85)))
        suite.expect(handEdited.sanitized().away == away.away,
                     "a stretch that ends before it starts is dropped on load")
        var orphaned = away
        orphaned.entries[0].end = at(80)
        suite.expect(orphaned.sanitized().away.isEmpty,
                     "time away without a running entry is dropped on load")

        var tracker = TimeTrackingAwayTracker()
        tracker.begin(.lock, at: at(0))
        tracker.begin(.sleep, at: at(1))
        suite.expect(tracker.end(.sleep, at: at(30)) == nil
                         && tracker.end(.lock, at: at(31)) == TimeAway(start: at(0), end: at(31)),
                     "overlapping reasons make one stretch, from the first start to the last end")
        suite.expect(tracker.end(.lock, at: at(40)) == nil,
                     "an end without its start is ignored")
        let cutoff = TimeTrackingLog.awayCutoff
        suite.expect(tracker.idle(120, at: at(50), cutoff: cutoff) == nil && tracker.reasons.isEmpty,
                     "two minutes without input is not idling")
        suite.expect(tracker.idle(6 * 60, at: at(56), cutoff: cutoff) == nil
                         && tracker.since == at(50),
                     "idling starts at the last input once it is five minutes old")
        suite.expect(tracker.idle(30, at: at(80), cutoff: cutoff) == TimeAway(start: at(50), end: at(79.5)),
                     "idling ends at the input that broke it")

        // MARK: Command Bar and shortcut

        for language in AppLanguage.allCases {
            let commands = FeatureStrings.timeTrackingCommands(language)
            let values = Mirror(reflecting: commands).children.compactMap { $0.value as? String }
            suite.expect(values.allSatisfy { !$0.isEmpty && !$0.contains("\u{2014}") && !$0.contains("...") },
                         "time tracking command strings are complete, without em dashes or three periods (\(language.rawValue))")
            let formats = [commands.continueFormat, commands.startedFormat, commands.stoppedFormat]
            suite.expect(formats.allSatisfy { $0.components(separatedBy: "%@").count == 2 },
                         "each command format names the entry exactly once (\(language.rawValue))")
            if language != .enUS {
                suite.expect(commands.startTimer != TimeTrackingCommandStrings.enUS.startTimer
                                 && commands.shortcutTitle != TimeTrackingCommandStrings.enUS.shortcutTitle,
                             "the command names are translated (\(language.rawValue))")
            }
        }
        for language in AppLanguage.allCases {
            let strings = FeatureStrings.timeTrackingAway(language)
            let values = Mirror(reflecting: strings).children.compactMap { $0.value as? String }
            suite.expect(values.allSatisfy { !$0.isEmpty && !$0.contains("\u{2014}") && !$0.contains("...") }
                             && strings.awayFormat.components(separatedBy: "%@").count == 2,
                         "the time away question is complete and names the time once (\(language.rawValue))")
            if language != .enUS {
                suite.expect(strings.discardAndStop != TimeTrackingAwayStrings.enUS.discardAndStop,
                             "the time away question is translated (\(language.rawValue))")
            }
        }
        let role = GlobalShortcutRole.timeTracking
        suite.expect(role.feature == .timeTracking && role.defaultShortcut == .timeTrackingDefault
                         && role.storageKey == DefaultsKey.timeTrackingShortcut
                         && role.requiredEnableKeys == [DefaultsKey.timeTrackingShortcutEnabled],
                     "the start or stop shortcut is wired to its own keys and the time tracking feature")
        suite.expect(Defaults.registeredDefaults[DefaultsKey.timeTrackingShortcutEnabled] as? Bool == false
                         && Defaults.registeredDefaults[DefaultsKey.timeTrackingShortcut] as? String
                         == GlobalShortcut.timeTrackingDefault.storageValue,
                     "the shortcut starts switched off, on its own default combination")
    }
}
