// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Why a correction cannot be saved. Overlaps are refused so no minute is
/// ever counted twice in the totals.
enum TimeEntryEditProblem: Equatable {
    case endBeforeStart
    case inFuture
    case overlaps
}

extension TimeTrackingLog {
    /// What stops these times from being saved, or nil when they can be.
    /// `id` is the entry being corrected, nil for a new one; a running entry
    /// passes no `end` and counts as ending now.
    func problem(editing id: UUID?, start: Date, end: Date?, now: Date) -> TimeEntryEditProblem? {
        let upper = end ?? now
        if start > now || upper > now { return .inFuture }
        if let end, end <= start { return .endBeforeStart }
        let overlaps = entries.contains { other in
            other.id != id && start < (other.end ?? now) && other.start < upper
        }
        return overlaps ? .overlaps : nil
    }

    /// Corrects an entry's times. A running entry only takes a new start and
    /// keeps running; a stopped one needs both.
    @discardableResult
    mutating func setTimes(_ id: UUID, start: Date, end: Date?, now: Date) -> Bool {
        guard let index = entries.firstIndex(where: { $0.id == id }),
              entries[index].isRunning == (end == nil),
              problem(editing: id, start: start, end: end, now: now) == nil else { return false }
        entries[index].start = start
        entries[index].end = end
        entries.sort { $0.start < $1.start }
        // Time away from before a later start no longer belongs to the entry.
        away = Self.repairedAway(away, for: running)
        return true
    }

    /// Adds an entry that was never timed, in its place among the others.
    @discardableResult
    mutating func addEntry(description: String, start: Date, end: Date, now: Date,
                           id: UUID = UUID()) -> UUID? {
        guard problem(editing: nil, start: start, end: end, now: now) == nil else { return nil }
        entries.append(TimeEntry(id: id, description: Self.cleaned(description), start: start, end: end))
        entries.sort { $0.start < $1.start }
        return id
    }
}
