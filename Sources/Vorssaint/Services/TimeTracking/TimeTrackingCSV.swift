// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Every entry as a spreadsheet row: local dates and times to the minute, and
/// whole minutes rounded up like everywhere else in the feature. A running
/// entry has no end yet and counts up to `now`. Pure, so the format is pinned
/// by tests.
enum TimeTrackingCSV {
    static func make(_ log: TimeTrackingLog, header: [String], now: Date,
                     timeZone: TimeZone = .autoupdatingCurrent) -> String {
        let date = formatter("yyyy-MM-dd", timeZone: timeZone)
        let time = formatter("HH:mm", timeZone: timeZone)
        var lines = [header.map(field).joined(separator: ",")]
        for entry in log.entries {
            let minutes = Int((entry.duration(at: now) / 60).rounded(.up))
            let row = [
                entry.description,
                date.string(from: entry.start), time.string(from: entry.start),
                entry.end.map { date.string(from: $0) } ?? "", entry.end.map { time.string(from: $0) } ?? "",
                String(minutes),
            ]
            lines.append(row.map(field).joined(separator: ","))
        }
        // CRLF line ends, as the CSV format asks for.
        return lines.joined(separator: "\r\n") + "\r\n"
    }

    /// UTF-8 with a byte order mark, so Excel reads names in any script.
    static func data(_ csv: String) -> Data {
        Data([0xEF, 0xBB, 0xBF]) + Data(csv.utf8)
    }

    static func fileName(title: String, date: Date, timeZone: TimeZone = .autoupdatingCurrent) -> String {
        "\(title) \(formatter("yyyy-MM-dd", timeZone: timeZone).string(from: date)).csv"
    }

    /// Quoted when it holds a comma, a quote or a line break. A description
    /// a spreadsheet would run as a formula is kept as text with a leading
    /// apostrophe.
    static func field(_ value: String) -> String {
        var text = value
        if let first = text.unicodeScalars.first, "=+-@\t\r".unicodeScalars.contains(first) {
            text = "'" + text
        }
        guard text.contains(where: { $0 == "," || $0 == "\"" || $0.isNewline }) else { return text }
        return "\"" + text.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    private static func formatter(_ format: String, timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        return formatter
    }
}
