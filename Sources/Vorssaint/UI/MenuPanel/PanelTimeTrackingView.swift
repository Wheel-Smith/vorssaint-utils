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

    var onClose: () -> Void

    private var strings: TimeTrackingFeatureStrings { FeatureStrings.timeTracking(l10n.language) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            if service.saveFailed {
                Label(strings.saveFailed, systemImage: "exclamationmark.triangle")
                    .font(.system(size: 10.5)).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .panelCard()
            }
            if let running = service.running {
                runningCard(running)
            } else {
                startCard
            }
            totalsCard
            recentList
            Toggle(strings.showInMenuBar, isOn: $showsMenuBarTimer)
                .toggleStyle(.checkbox)
                .font(.system(size: 10.5))
        }
        .onAppear { PanelInteractionState.shared.viewKeepsPopoverOpen = true }
        .onDisappear {
            PanelInteractionState.shared.viewKeepsPopoverOpen = false
            // Escape on the island steps back before the field sees it.
            renamingID = nil
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var header: some View {
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

    @ViewBuilder
    private var recentList: some View {
        let recent = service.log.recent(limit: 5)
        if !recent.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(strings.recent)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                ForEach(recent) { entry in
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
                renameText = entry.description
                renamingID = entry.id
            }
            Divider()
            Button(strings.delete, role: .destructive) { service.delete(entry.id) }
        }
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
