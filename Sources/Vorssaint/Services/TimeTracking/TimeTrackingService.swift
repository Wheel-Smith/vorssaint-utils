// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Combine
import Foundation

/// The live log behind the panel and the menu bar timer. Nothing here runs on
/// a timer: a running entry is only a start date, so the elapsed time is
/// computed whenever something draws it, across quits and restarts alike.
final class TimeTrackingService: ObservableObject {
    static let shared = TimeTrackingService()

    @Published private(set) var log = TimeTrackingLog()
    /// True while the file could not be read or the last change could not be
    /// written. Changes are refused while the file is unreadable, so a
    /// damaged log is never replaced by an empty one.
    @Published private(set) var saveFailed = false

    private var store = TimeTrackingStore(directoryURL: PrivateFileStore.containerURL)
    private var hasLoaded = false

    private init() {
        load()
    }

    var running: TimeEntry? { log.running }

    func start(description: String) {
        mutate { $0.start(description: description, at: Date()) }
    }

    func stop() {
        mutate { $0.stop(at: Date()) }
    }

    func continueEntry(_ id: UUID) {
        mutate { $0.continueEntry(id, at: Date()) }
    }

    func resumeLatest(fallback: String) {
        mutate { $0.resumeLatest(at: Date(), fallback: fallback) }
    }

    func rename(_ id: UUID, to description: String) {
        mutate { $0.rename(id, to: description) }
    }

    func delete(_ id: UUID) {
        mutate { $0.delete(id) }
    }

    func setTimes(_ id: UUID, start: Date, end: Date?) {
        mutate { $0.setTimes(id, start: start, end: end, now: Date()) }
    }

    func addEntry(description: String, start: Date, end: Date) {
        mutate { $0.addEntry(description: description, start: start, end: end, now: Date()) }
    }

    func noteAway(_ stretch: TimeAway) {
        mutate { $0.noteAway(from: stretch.start, to: stretch.end) }
    }

    func keepAway() {
        mutate { $0.keepAway() }
    }

    func discardAway(stopping: Bool) {
        mutate { $0.discardAway(stopping: stopping) }
    }

    private func load() {
        do {
            log = try store.load()
            hasLoaded = true
            saveFailed = false
        } catch {
            hasLoaded = false
            saveFailed = true
        }
    }

    private func mutate(_ change: (inout TimeTrackingLog) -> Void) {
        if !hasLoaded { load() }
        guard hasLoaded else { return }
        var next = log
        change(&next)
        guard next != log else { return }
        log = next
        saveFailed = !store.save(next)
    }
}
