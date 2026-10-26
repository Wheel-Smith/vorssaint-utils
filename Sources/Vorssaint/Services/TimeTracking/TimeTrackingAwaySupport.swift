// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// A stretch away from the Mac (asleep, locked, switched to another user or
/// without input) while the running entry ran.
struct TimeAway: Codable, Equatable {
    var start: Date
    var end: Date

    var duration: TimeInterval { max(0, end.timeIntervalSince(start)) }
}

extension TimeTrackingLog {
    /// Shorter stretches are a coffee or a phone call, not a forgotten timer.
    static let awayCutoff: TimeInterval = 5 * 60

    var awayDuration: TimeInterval { away.reduce(0) { $0 + $1.duration } }

    /// Records a stretch away while an entry runs. Only the part after the
    /// entry started counts, a stretch under the cutoff is ignored, and one
    /// overlapping an earlier stretch joins it.
    mutating func noteAway(from start: Date, to end: Date) {
        guard let running else { return }
        let start = max(start, running.start)
        guard end.timeIntervalSince(start) >= Self.awayCutoff else { return }
        var merged = TimeAway(start: start, end: end)
        var kept: [TimeAway] = []
        for stretch in away {
            if stretch.end >= merged.start && stretch.start <= merged.end {
                merged = TimeAway(start: min(stretch.start, merged.start), end: max(stretch.end, merged.end))
            } else {
                kept.append(stretch)
            }
        }
        away = (kept + [merged]).sorted { $0.start < $1.start }
    }

    /// The time away counts as worked.
    mutating func keepAway() {
        away = []
    }

    /// Takes the time away out of the running entry. The entry is cut at each
    /// stretch, so the work before and between them keeps its own entries,
    /// and it runs on after the last one unless `stopping`, which ends it
    /// where the last stretch began.
    mutating func discardAway(stopping: Bool, newID: () -> UUID = { UUID() }) {
        guard let running, let index = entries.firstIndex(where: { $0.id == running.id }),
              !away.isEmpty else { return }
        let description = running.description
        var pieces: [TimeEntry] = []
        var pieceStart = running.start
        for stretch in away {
            if stretch.start > pieceStart {
                let id = pieces.isEmpty ? running.id : newID()
                pieces.append(TimeEntry(id: id, description: description, start: pieceStart, end: stretch.start))
            }
            pieceStart = max(pieceStart, stretch.end)
        }
        if !stopping {
            let id = pieces.isEmpty ? running.id : newID()
            pieces.append(TimeEntry(id: id, description: description, start: pieceStart, end: nil))
        }
        entries.replaceSubrange(index...index, with: pieces)
        away = []
    }

    /// Keeps only stretches that belong to the running entry and make sense,
    /// for a file edited by hand.
    static func repairedAway(_ away: [TimeAway], for running: TimeEntry?) -> [TimeAway] {
        guard let running else { return [] }
        return away
            .filter { $0.end > $0.start && $0.end > running.start }
            .map { TimeAway(start: max($0.start, running.start), end: $0.end) }
            .sorted { $0.start < $1.start }
    }
}

/// Works out stretches away from the events the watcher hears. Several
/// reasons can overlap (a Mac that locks as it goes to sleep), and the
/// stretch runs from the first one starting until none is left.
struct TimeTrackingAwayTracker {
    enum Reason: Hashable {
        case sleep, lock, switchedOut, idle
    }

    private(set) var reasons: Set<Reason> = []
    private(set) var since: Date?

    mutating func begin(_ reason: Reason, at date: Date) {
        since = min(since ?? date, date)
        reasons.insert(reason)
    }

    /// The finished stretch, once nothing keeps the person away any more.
    mutating func end(_ reason: Reason, at date: Date) -> TimeAway? {
        guard reasons.remove(reason) != nil, reasons.isEmpty, let since else { return nil }
        self.since = nil
        return TimeAway(start: since, end: max(since, date))
    }

    /// One reading of how long ago the last keyboard or mouse input was.
    /// Idling starts at that input once it is `cutoff` old, and ends at the
    /// input that broke it.
    mutating func idle(_ seconds: TimeInterval, at now: Date, cutoff: TimeInterval) -> TimeAway? {
        let lastInput = now.addingTimeInterval(-max(0, seconds))
        if seconds >= cutoff {
            if !reasons.contains(.idle) { begin(.idle, at: lastInput) }
            return nil
        }
        guard reasons.contains(.idle) else { return nil }
        return end(.idle, at: lastInput)
    }

    mutating func reset() {
        reasons = []
        since = nil
    }
}
