// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

struct PanelTimeTrackingView: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var service = TimeTrackingService.shared
    @AppStorage(DefaultsKey.timeTrackingMenuBarTimer) private var showsMenuBarTimer = true
    @State private var draft = ""
    @State private var period = AgentPeriod.today
    @State private var renamingID: UUID?
    @State private var renameText = ""
    /// The entry whose times are being corrected, in place like a rename.
    @State private var editingID: UUID?
    @State private var isAdding = false
    @State private var addName = ""
    @State private var editStart = Date()
    @State private var editEnd = Date()

    /// nil on the island's own page, whose band already names it.
    var onClose: (() -> Void)? = nil

    private var strings: TimeTrackingFeatureStrings { FeatureStrings.timeTracking(l10n.language) }
    private var edit: TimeTrackingEditStrings { FeatureStrings.timeTrackingEdit(l10n.language) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let onClose { header(onClose) }
            if service.saveFailed {
                Label(strings.saveFailed, systemImage: "exclamationmark.triangle")
                    .font(.system(size: 10.5)).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .panelCard()
            }
            if let running = service.running {
                if !service.log.away.isEmpty { awayCard }
                if editingID == running.id {
                    timesEditor(running)
                } else {
                    runningCard(running)
                }
            } else {
                startCard
            }
            totalsCard
            recentList
            if onClose != nil {
                Toggle(strings.showInMenuBar, isOn: $showsMenuBarTimer)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 10.5))
            }
        }
        // The island's own page is not in the popover, so it must not hold it.
        .onAppear { if onClose != nil { PanelInteractionState.shared.viewKeepsPopoverOpen = true } }
        .onDisappear {
            if onClose != nil { PanelInteractionState.shared.viewKeepsPopoverOpen = false }
            // Escape on the island steps back before the field sees it.
            renamingID = nil
            editingID = nil
            isAdding = false
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func header(_ onClose: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            Label(strings.title, systemImage: AppFeature.timeTracking.symbolName)
                .font(.system(size: 12, weight: .semibold))
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .help(l10n.s.uninstallerCancel)
        }
    }

    // MARK: Running and starting

    private func runningCard(_ entry: TimeEntry) -> some View {
        HStack(spacing: 8) {
            Text(name(entry.description))
                .font(.system(size: 11.5, weight: .semibold))
                .lineLimit(1)
            Spacer(minLength: 4)
            TimelineView(.periodic(from: entry.start, by: 1)) { context in
                Text(Self.elapsed(entry.duration(at: context.date)))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .monospacedDigit()
            }
            Button(strings.stop) { service.stop() }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .panelCard()
        .contextMenu {
            Button(edit.editStart) { beginEditing(entry) }
        }
    }

    /// Asked after time away from the Mac while the entry ran; it stays
    /// until answered or the entry stops, which keeps the time.
    private var awayCard: some View {
        let away = FeatureStrings.timeTrackingAway(l10n.language)
        return VStack(alignment: .leading, spacing: 6) {
            Label(String(format: away.awayFormat, TimeTrackingFormat.clock(service.log.awayDuration)),
                  systemImage: "zzz")
                .font(.system(size: 11, weight: .medium))
            HStack(spacing: 6) {
                Button(away.keep) { service.keepAway() }
                Button(away.discard) { service.discardAway(stopping: false) }
                Button(away.discardAndStop) { service.discardAway(stopping: true) }
            }
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .panelCard()
    }

    private var startCard: some View {
        HStack(spacing: 6) {
            TextField(strings.descriptionPlaceholder, text: $draft)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 11))
                .onSubmit(start)
            Button(strings.start, action: start)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .panelCard()
    }

    private func start() {
        service.start(description: draft)
        draft = ""
    }

    // MARK: Totals

    private var totalsCard: some View {
        TimelineView(.everyMinute) { context in
            let totals = service.log.totals(for: period, now: context.date)
            let longest = totals.first?.seconds ?? 0
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Picker("", selection: $period) {
                        ForEach(AgentPeriod.allCases) { option in
                            Text(periodStrings.period(option)).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    Spacer(minLength: 8)
                    Text(TimeTrackingFormat.clock(totals.reduce(0) { $0 + $1.seconds }))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .monospacedDigit()
                }
                if totals.isEmpty {
                    VStack(spacing: 2) {
                        Text(strings.empty)
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(strings.emptyHint)
                            .font(.system(size: 9.5))
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                } else {
                    ForEach(totals) { total in
                        totalRow(total, longest: longest)
                    }
                }
            }
        }
        .panelCard()
    }

    private func totalRow(_ total: TimeEntryTotal, longest: TimeInterval) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Text(name(total.description))
                    .font(.system(size: 10.5))
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text(TimeTrackingFormat.clock(total.seconds))
                    .font(.system(size: 10.5, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.primary.opacity(0.08))
                    Capsule().fill(Color.accentColor)
                        .frame(width: longest > 0 ? max(4, proxy.size.width * total.seconds / longest) : 0)
                }
            }
            .frame(height: 4)
        }
    }

    // MARK: Recent

    private var recentList: some View {
        let recent = service.log.recent(limit: 5)
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                if !recent.isEmpty {
                    Text(strings.recent)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !service.log.entries.isEmpty {
                    let export = FeatureStrings.timeTrackingExport(l10n.language).exportCSV
                    Button { TimeTrackingExport.run(fromIsland: onClose == nil) } label: {
                        Image(systemName: "square.and.arrow.up").font(.system(size: 10))
                    }
                    .buttonStyle(.borderless)
                    .help(export)
                    .accessibilityLabel(export)
                }
                Button(action: beginAdding) {
                    Image(systemName: "plus").font(.system(size: 10))
                }
                .buttonStyle(.borderless)
                .disabled(isAdding)
                .help(edit.addEntry)
                .accessibilityLabel(edit.addEntry)
            }
            if isAdding { addEditor }
            ForEach(recent) { entry in
                if editingID == entry.id {
                    timesEditor(entry)
                } else {
                    recentRow(entry)
                }
            }
        }
    }

    private func recentRow(_ entry: TimeEntry) -> some View {
        HStack(spacing: 8) {
            // Renamed in place: an alert would hang from the island as a
            // sheet when the panel is shown there.
            if renamingID == entry.id {
                TextField(strings.descriptionPlaceholder, text: $renameText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 10.5))
                    .onSubmit {
                        service.rename(entry.id, to: renameText)
                        renamingID = nil
                    }
                    .onExitCommand { renamingID = nil }
            } else {
                Text(name(entry.description))
                    .font(.system(size: 10.5))
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            Text(TimeTrackingFormat.clock(entry.duration(at: Date())))
                .font(.system(size: 10, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.secondary)
            Button { service.continueEntry(entry.id) } label: {
                Image(systemName: "play.fill").font(.system(size: 10))
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
            .help(strings.continueEntry)
            .accessibilityLabel(strings.continueEntry)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 6))
        .contentShape(Rectangle())
        .contextMenu {
            Button(strings.continueEntry) { service.continueEntry(entry.id) }
            Button(strings.rename) {
                editingID = nil
                isAdding = false
                renameText = entry.description
                renamingID = entry.id
            }
            Button(edit.editTimes) { beginEditing(entry) }
            Divider()
            Button(strings.delete, role: .destructive) { service.delete(entry.id) }
        }
    }

    // MARK: Correcting times

    /// The newest entry of a Recent row, like Delete, or the running one,
    /// which only takes a new start.
    private func timesEditor(_ entry: TimeEntry) -> some View {
        let end = entry.isRunning ? nil : editEnd
        return timesCard(problem: service.log.problem(editing: entry.id, start: editStart, end: end, now: Date()),
                         showsEnd: !entry.isRunning,
                         onSave: {
                             service.setTimes(entry.id, start: editStart, end: end)
                             editingID = nil
                         },
                         onCancel: { editingID = nil }) {
            Text(name(entry.description))
                .font(.system(size: 10.5, weight: .semibold))
                .lineLimit(1)
        }
    }

    private var addEditor: some View {
        timesCard(problem: service.log.problem(editing: nil, start: editStart, end: editEnd, now: Date()),
                  showsEnd: true,
                  onSave: {
                      service.addEntry(description: addName, start: editStart, end: editEnd)
                      isAdding = false
                  },
                  onCancel: { isAdding = false }) {
            TextField(strings.descriptionPlaceholder, text: $addName)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 10.5))
        }
    }

    private func timesCard<Title: View>(problem: TimeEntryEditProblem?,
                                        showsEnd: Bool,
                                        onSave: @escaping () -> Void,
                                        onCancel: @escaping () -> Void,
                                        @ViewBuilder title: () -> Title) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            title()
            timeRow(edit.startLabel, selection: $editStart)
            if showsEnd { timeRow(edit.endLabel, selection: $editEnd) }
            if let problem {
                Text(message(for: problem))
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 6) {
                Spacer()
                Button(edit.cancel, action: onCancel)
                Button(edit.save, action: onSave)
                    .buttonStyle(.borderedProminent)
                    .disabled(problem != nil)
            }
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .panelCard()
    }

    private func timeRow(_ label: String, selection: Binding<Date>) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10.5))
                .foregroundStyle(.secondary)
            Spacer(minLength: 6)
            DatePicker(label, selection: selection, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.field)
                .controlSize(.small)
                .labelsHidden()
                .fixedSize()
        }
    }

    private func message(for problem: TimeEntryEditProblem) -> String {
        switch problem {
        case .endBeforeStart: return edit.endBeforeStart
        case .inFuture: return edit.inFuture
        case .overlaps: return edit.overlaps
        }
    }

    private func beginEditing(_ entry: TimeEntry) {
        renamingID = nil
        isAdding = false
        editStart = entry.start
        editEnd = entry.end ?? Date()
        editingID = entry.id
    }

    /// Starts as the half hour that ended at the last whole minute: the
    /// usual case is work done without starting the timer.
    private func beginAdding() {
        renamingID = nil
        editingID = nil
        let minute = Date(timeIntervalSinceReferenceDate:
            (Date().timeIntervalSinceReferenceDate / 60).rounded(.down) * 60)
        editEnd = minute
        editStart = minute.addingTimeInterval(-30 * 60)
        addName = ""
        isAdding = true
    }

    // MARK: Helpers

    /// The AI agents view already names these periods in every language.
    private var periodStrings: NotchAgentStrings { FeatureStrings.notchAgents(l10n.language) }

    private func name(_ description: String) -> String {
        description.isEmpty ? strings.untitled : description
    }

    /// The panel shows seconds so a just-started timer visibly moves; the
    /// menu bar keeps to minutes.
    private static func elapsed(_ seconds: TimeInterval) -> String {
        let total = Int(max(0, seconds))
        return String(format: "%d:%02d:%02d", total / 3600, total / 60 % 60, total % 60)
    }
}
