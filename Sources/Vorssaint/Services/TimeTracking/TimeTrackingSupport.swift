// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// One stretch of tracked time. `end` is nil only while it runs.
struct TimeEntry: Codable, Equatable, Identifiable {
    let id: UUID
    var description: String
    var start: Date
    var end: Date?

    var isRunning: Bool { end == nil }

    /// Seconds tracked up to `now`. A clock set back while it ran must not
    /// produce negative time.
    func duration(at now: Date) -> TimeInterval {
        max(0, (end ?? now).timeIntervalSince(start))
    }
}

/// Time spent on one description over a period. Descriptions that differ
/// only in case count as one; `description` is the latest spelling, and an
/// empty one stands for the entries without a description.
struct TimeEntryTotal: Equatable, Identifiable {
    let description: String
    var seconds: TimeInterval

    var id: String { description.lowercased() }
}

/// Everything the feature stores. All changes go through these methods so
/// the one-running-entry rule cannot be broken from a view.
struct TimeTrackingLog: Codable, Equatable {
    static let maximumDescriptionLength = 200

    /// Oldest first.
    var entries: [TimeEntry] = []
    /// Stretches away from the Mac while the running entry ran, oldest first,
    /// waiting for the person to keep or discard them. Only ever about the
    /// running entry: stopping it keeps them.
    var away: [TimeAway] = []

    init(entries: [TimeEntry] = [], away: [TimeAway] = []) {
        self.entries = entries
        self.away = away
    }

    /// Decoded a field at a time, so a file written before time away was
    /// kept still loads. Here rather than beside the rest of time away,
    /// because the synthesized coding keys are private to this file.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        entries = try container.decodeIfPresent([TimeEntry].self, forKey: .entries) ?? []
        away = try container.decodeIfPresent([TimeAway].self, forKey: .away) ?? []
    }

    var running: TimeEntry? { entries.last(where: \.isRunning) }

    // MARK: Entries

    /// Starting stops whatever runs, so time is never counted twice.
    @discardableResult
    mutating func start(description: String, at now: Date, id: UUID = UUID()) -> UUID {
        stop(at: now)
        entries.append(TimeEntry(id: id, description: Self.cleaned(description), start: now, end: nil))
        return id
    }

    /// A start in the future (the clock moved back) ends at its own start
    /// instead of before it.
    mutating func stop(at now: Date) {
        away = []
        for index in entries.indices where entries[index].isRunning {
            entries[index].end = max(entries[index].start, now)
        }
    }

    /// Starts a new entry with the same description.
    @discardableResult
    mutating func continueEntry(_ id: UUID, at now: Date, newID: UUID = UUID()) -> UUID? {
        guard let entry = entries.first(where: { $0.id == id }) else { return nil }
        return start(description: entry.description, at: now, id: newID)
    }

    /// Renames every entry with the same description, ignoring case, so a
    /// typo is fixed in the totals too: they group by description.
    mutating func rename(_ id: UUID, to description: String) {
        guard let old = entries.first(where: { $0.id == id })?.description.lowercased() else { return }
        let new = Self.cleaned(description)
        for index in entries.indices where entries[index].description.lowercased() == old {
            entries[index].description = new
        }
    }

    mutating func delete(_ id: UUID) {
        if running?.id == id { away = [] }
        entries.removeAll { $0.id == id }
    }

    // MARK: Reports

    /// The same windows as the AI agents view: today from local midnight, and
    /// 7 or 30 days as that many calendar days ending today.
    static func periodStart(_ period: AgentPeriod, now: Date, calendar: Calendar) -> Date {
        let today = calendar.startOfDay(for: now)
        return calendar.date(byAdding: .day, value: -(period.days - 1), to: today) ?? today
    }

    /// Only the part of each entry inside the period counts, so an entry that
    /// ran over midnight is split between the days it covered.
    func totals(for period: AgentPeriod, now: Date, calendar: Calendar = .autoupdatingCurrent) -> [TimeEntryTotal] {
        let lower = Self.periodStart(period, now: now, calendar: calendar)
        var totals: [String: TimeEntryTotal] = [:]
        for entry in entries {
            let from = max(entry.start, lower)
            let to = min(entry.end ?? now, now)
            guard to > from else { continue }
            let key = entry.description.lowercased()
            let seconds = (totals[key]?.seconds ?? 0) + to.timeIntervalSince(from)
            totals[key] = TimeEntryTotal(description: entry.description, seconds: seconds)
        }
        return totals.values.sorted { $0.seconds != $1.seconds ? $0.seconds > $1.seconds : $0.id < $1.id }
    }

    func total(for period: AgentPeriod, now: Date, calendar: Calendar = .autoupdatingCurrent) -> TimeInterval {
        totals(for: period, now: now, calendar: calendar).reduce(0) { $0 + $1.seconds }
    }

    /// Stopped entries newest first, one per description, for
    /// starting the same work again with one click.
    func recent(limit: Int) -> [TimeEntry] {
        var seen = Set<String>()
        var result: [TimeEntry] = []
        for entry in entries.reversed() where !entry.isRunning {
            guard seen.insert(entry.description.lowercased()).inserted else { continue }
            result.append(entry)
            if result.count == limit { break }
        }
        return result
    }

    // MARK: Loading

    /// Repairs a file edited by hand or written by a future version: entries
    /// that end before they start are dropped and only the latest of several
    /// running entries keeps running. The decoder ignores fields this version
    /// does not know, so a file from another version still loads.
    func sanitized() -> TimeTrackingLog {
        var entryIDs = Set<UUID>()
        var kept = entries.filter { entry in
            guard entryIDs.insert(entry.id).inserted else { return false }
            if let end = entry.end { return end >= entry.start }
            return true
        }
        kept.sort { $0.start < $1.start }
        let latestRunning = kept.last(where: \.isRunning)?.id
        for index in kept.indices {
            kept[index].description = Self.cleaned(kept[index].description)
            if kept[index].isRunning, kept[index].id != latestRunning {
                kept[index].end = kept[index].start
            }
        }
        var repaired = TimeTrackingLog(entries: kept)
        repaired.away = Self.repairedAway(away, for: repaired.running)
        return repaired
    }

    private static func cleaned(_ text: String) -> String {
        let singleLine = text.components(separatedBy: .newlines).joined(separator: " ")
        return String(singleLine.trimmingCharacters(in: .whitespaces).prefix(maximumDescriptionLength))
    }
}

enum TimeTrackingFormat {
    /// "0:42" under ten hours, "12:05" above, never seconds: the menu bar
    /// item changes once a minute. A started minute counts as a whole one,
    /// so 8 minutes 30 seconds reads 0:09.
    static func clock(_ seconds: TimeInterval) -> String {
        let minutes = Int((max(0, seconds) / 60).rounded(.up))
        return String(format: "%d:%02d", minutes / 60, minutes % 60)
    }

    /// Half a second after the next minute boundary of an entry started at
    /// `start`. A reading rounded up changes just after the boundary, so a
    /// refresh on the boundary itself would still draw the old minute.
    static func nextMinuteBoundary(after now: Date, start: Date) -> Date {
        let elapsed = max(0, now.timeIntervalSince(start))
        let next = (((elapsed - 0.5) / 60).rounded(.down) + 1) * 60 + 0.5
        return start.addingTimeInterval(next)
    }
}
