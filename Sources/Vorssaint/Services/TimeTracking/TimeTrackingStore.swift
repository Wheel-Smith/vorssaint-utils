// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Reads and writes the log in the app's owner-only container. A failed read
/// must never authorize a later save: an unreadable file would otherwise be
/// replaced by an empty log and every entry lost.
struct TimeTrackingStore {
    static let fileName = "TimeTracking.json"

    let directoryURL: URL?
    private(set) var lastSavedLog: TimeTrackingLog?
    private var canSave = false

    init(directoryURL: URL?) {
        self.directoryURL = directoryURL
    }

    private var fileURL: URL? { directoryURL?.appendingPathComponent(Self.fileName) }

    /// No file yet is an empty log; anything unreadable throws and leaves
    /// saving disabled until a later load succeeds.
    mutating func load() throws -> TimeTrackingLog {
        canSave = false
        lastSavedLog = nil
        guard let fileURL else { throw CocoaError(.fileReadUnknown) }
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
            canSave = true
            return TimeTrackingLog()
        }
        let decoded = try JSONDecoder.timeTracking.decode(TimeTrackingLog.self, from: data)
        lastSavedLog = decoded
        canSave = true
        return decoded.sanitized()
    }

    @discardableResult
    mutating func save(_ log: TimeTrackingLog) -> Bool {
        guard canSave else { return false }
        if log == lastSavedLog { return true }
        guard let directoryURL, let fileURL,
              let data = try? JSONEncoder.timeTracking.encode(log) else { return false }
        guard PrivateFileStore.createDirectory(at: directoryURL),
              PrivateFileStore.write(data, to: fileURL),
              (try? Data(contentsOf: fileURL)) == data else { return false }
        lastSavedLog = log
        return true
    }
}

private extension JSONEncoder {
    static var timeTracking: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    static var timeTracking: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
