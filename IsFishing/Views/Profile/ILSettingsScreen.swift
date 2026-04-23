import SwiftUI
import UIKit

struct ILSettingsScreen: View {
    @Binding var toast: String?
    @EnvironmentObject private var router: ILAppRouter
    @EnvironmentObject private var store: ILPersistenceStore
    @State private var showPrivacy = false
    @State private var dialog: SettingsDialog?

    enum SettingsDialog: Identifiable {
        case resetStats, resetNotes, resetSessions, resetSpots, resetGames, resetAll, resetOnboarding
        var id: String {
            switch self {
            case .resetStats: return "stats"
            case .resetNotes: return "notes"
            case .resetSessions: return "sessions"
            case .resetSpots: return "spots"
            case .resetGames: return "games"
            case .resetAll: return "all"
            case .resetOnboarding: return "onboarding"
            }
        }
    }

    var body: some View {
        ZStack {
            ILAtmosphereBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ILScreenHeroHeader(kicker: "App", title: "Settings", systemIcon: "gearshape.fill") {
                        EmptyView()
                    }
                    settingsSection(title: "Data Management") {
                        resetRow("Reset Statistics", subtitle: "Clears article and species view tracking.") { dialog = .resetStats }
                        Divider().background(ILTheme.divider).padding(.leading, 16)
                        resetRow("Reset Notes", subtitle: "Deletes all notes and attached photos.") { dialog = .resetNotes }
                        Divider().background(ILTheme.divider).padding(.leading, 16)
                        resetRow("Reset Sessions", subtitle: "Deletes all sessions, catch logs, and session photos.") { dialog = .resetSessions }
                        Divider().background(ILTheme.divider).padding(.leading, 16)
                        resetRow("Reset Map Spots", subtitle: "Deletes all map spots and attached photos.") { dialog = .resetSpots }
                        Divider().background(ILTheme.divider).padding(.leading, 16)
                        resetRow("Reset Game Progress", subtitle: "Resets Trophy Points, high scores, and tier to Novice.") { dialog = .resetGames }
                        Divider().background(ILTheme.divider).padding(.leading, 16)
                        resetRow("Erase All Data", subtitle: "Deletes everything and shows onboarding again.") { dialog = .resetAll }
                    }
                    settingsSection(title: "Onboarding") {
                        resetRow("Reset Onboarding", subtitle: "Shows the welcome walkthrough again.") { dialog = .resetOnboarding }
                    }
                    settingsSection(title: "About") {
                        Button {
                            showPrivacy = true
                        } label: {
                            HStack {
                                Text("Privacy Policy")
                                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                                    .foregroundStyle(ILTheme.textPrimaryOnDark)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(ILTheme.textMutedOnDark)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                        Divider().background(ILTheme.divider).padding(.leading, 16)
                        HStack {
                            Text("Version")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(ILTheme.textPrimaryOnDark)
                            Spacer()
                            Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(ILTheme.textMutedOnDark)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPrivacy) {
            NavigationStack {
                ILPrivacyWebView(url: URL(string: "https://sites.google.com/view/isfishing")!)
                    .navigationTitle("Privacy")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showPrivacy = false }
                        }
                    }
            }
        }
        .overlay {
            if let d = dialog {
                confirmation(for: d)
            }
        }
        .ilTracksProfileNavigationDepth(router)
    }

    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(ILTheme.textMutedOnDark)
                .padding(.leading, 4)
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .ilCard()
        }
    }

    @ViewBuilder
    private func confirmation(for d: SettingsDialog) -> some View {
        switch d {
        case .resetStats:
            ILConfirmationDialog(
                title: "Reset Statistics?",
                message: "This clears tracked reading progress: which guide articles you opened and which species detail screens you viewed.",
                confirmTitle: "Reset",
                onConfirm: { dialog = nil; store.resetStatisticsTracking(); toast = "Done" },
                onCancel: { dialog = nil }
            )
        case .resetNotes:
            ILConfirmationDialog(
                title: "Delete All Notes?",
                message: "This will permanently delete all your notes and their attached photos.",
                confirmTitle: "Delete",
                onConfirm: { dialog = nil; store.resetNotes(); toast = "Done" },
                onCancel: { dialog = nil }
            )
        case .resetSessions:
            ILConfirmationDialog(
                title: "Delete All Sessions?",
                message: "This will permanently delete all fishing sessions, catch logs, and session photos. Your map spots will not be affected.",
                confirmTitle: "Delete",
                onConfirm: { dialog = nil; store.resetSessions(); toast = "Done" },
                onCancel: { dialog = nil }
            )
        case .resetSpots:
            ILConfirmationDialog(
                title: "Delete All Map Spots?",
                message: "This will permanently delete all your map spots and their attached photos. Sessions linked to spots will keep their data but lose the spot reference.",
                confirmTitle: "Delete",
                onConfirm: { dialog = nil; store.resetMapSpots(); toast = "Done" },
                onCancel: { dialog = nil }
            )
        case .resetGames:
            ILConfirmationDialog(
                title: "Reset Game Progress?",
                message: "This resets Trophy Points to zero, Trophy Tier to Novice, high scores, games played counts, and your best streak in Marked Catch.",
                confirmTitle: "Reset",
                onConfirm: { dialog = nil; store.resetGameProgress(); toast = "Done" },
                onCancel: { dialog = nil }
            )
        case .resetAll:
            ILConfirmationDialog(
                title: "Erase All Data?",
                message: "This permanently deletes all sessions, map spots, notes, attached photos, game progress, statistics tracking, and resets your profile to defaults. Onboarding will be shown again.",
                confirmTitle: "Erase",
                onConfirm: { dialog = nil; store.resetAllUserData(); toast = "Done" },
                onCancel: { dialog = nil }
            )
        case .resetOnboarding:
            ILConfirmationDialog(
                title: "Reset Onboarding?",
                message: "Shows the welcome walkthrough again.",
                confirmTitle: "Reset",
                onConfirm: { dialog = nil; store.setOnboardingCompleted(false); toast = "Done" },
                onCancel: { dialog = nil }
            )
        }
    }

    private func resetRow(_ title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(ILTheme.tertiaryRed)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(ILTheme.textMutedOnDark)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(ILTheme.textMutedOnDark)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
