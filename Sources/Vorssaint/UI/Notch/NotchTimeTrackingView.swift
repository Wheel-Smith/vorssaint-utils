// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// The closed island while a time entry runs: a clock left of the camera,
/// and on the right the time the entry has run, as the menu bar item reads
/// it. Both open the Time Tracking page. The wings
/// are as wide as the wider side needs.
struct NotchTimeTrackingStrip: View {
    @ObservedObject var service: NotchService
    /// Where the island draws it: its own strip as of the last update, or
    /// another display's when the island shows on every display.
    var displayGeometry: NotchGeometry? = nil
    @ObservedObject private var tracking = TimeTrackingService.shared
    @ObservedObject private var l10n = L10n.shared

    var body: some View {
        // Stopping clears the entry before the strip has left.
        NotchStripHold(tracking.running, shows: tracking.running != nil) { entry in
            if let entry {
                // The reading changes once a minute, so the clock wakes only then.
                TimelineView(.periodic(from: NotchTimeTrackingSupport.tickStart(since: entry.start, now: Date()),
                                       by: 60)) { context in
                    strip(entry, now: context.date)
                }
            }
        }
    }

    private func strip(_ entry: TimeEntry, now: Date) -> some View {
        let geometry = displayGeometry ?? service.compactActivityGeometry
        let height = geometry.compactActivityContentHeight
        let wing = geometry.compactActivityWingWidth
        let iconSize = NotchTimerSupport.stripIconSize(height: height)
        let textSize = NotchTimerSupport.stripTextSize(height: height)
        let text = NotchTimeTrackingSupport.compactText(since: entry.start, now: now)
        return Button { service.openActivity(NotchCompactActivity.timeTracking.module) } label: {
            HStack(spacing: 0) {
                Group {
                    if wing >= 28 {
                        Image(systemName: NotchTimeTrackingSupport.symbol)
                            .font(.system(size: iconSize, weight: .medium))
                            .foregroundStyle(Self.tint)
                    }
                }
                .padding(.leading, geometry.compactActivityEdgeInset(boxHeight: iconSize, radius: iconSize / 2))
                .frame(width: wing, height: height, alignment: .leading)
                Color.clear.frame(width: geometry.compactActivityCameraGap)
                Group {
                    if wing >= 42 {
                        Text(text)
                            .font(.system(size: textSize, weight: .medium)).monospacedDigit()
                            .foregroundStyle(.white)
                            .lineLimit(1).minimumScaleFactor(0.65)
                            // A reading that gains a character, like 9:59
                            // becoming 10:00, resizes the wings; the service
                            // measures the same reading.
                            .onChange(of: NotchAgentSupport.readingShape(text)) { _, _ in
                                DispatchQueue.main.async { service.refreshPresentation() }
                            }
                    }
                }
                // Digits carry no descenders, so their ink is about the cap height.
                .padding(.trailing, geometry.compactActivityEdgeInset(boxHeight: textSize * 0.72, radius: 0))
                .frame(width: wing, height: height, alignment: .trailing)
            }
            .frame(height: height)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, geometry.compactActivityHorizontalPadding)
        .padding(.top, geometry.compactActivityTopPadding)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Self.label(entry, language: l10n.language))
        .accessibilityValue(text)
        .accessibilityHint(FeatureStrings.notch(l10n.language).open)
        .accessibilityIdentifier("notch.timeTracking")
    }

    /// The module's own colour in the island editor, so the clock is told
    /// apart from the timer's orange and Keep Awake's yellow.
    static let tint = Color(red: 0.6, green: 0.76, blue: 0.2)

    /// The entry read aloud, since the strip does not show it.
    static func label(_ entry: TimeEntry, language: AppLanguage) -> String {
        entry.description.isEmpty ? FeatureStrings.timeTracking(language).untitled : entry.description
    }
}

/// The island's Time Tracking page: the panel's own tool, in the island's
/// dark styling. The island's band already names the page, and the menu bar
/// item has its switch in the panel.
struct NotchTimeTrackingView: View {
    let size: CGSize

    var body: some View {
        ScrollView {
            PanelTimeTrackingView()
                .padding(.bottom, 4)
        }
        .scrollIndicators(.automatic)
        .frame(width: size.width, height: size.height, alignment: .top)
        .environment(\.notchPresentation, true)
        .environment(\.colorScheme, .dark)
    }
}
