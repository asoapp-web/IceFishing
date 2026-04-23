import SwiftUI

/// Theme picker only (not full Statistics) — opened from Profile “Reward theme” card.
struct ILRewardThemesScreen: View {
    @Binding var toast: String?
    @EnvironmentObject private var store: ILPersistenceStore
    @EnvironmentObject private var router: ILAppRouter

    var body: some View {
        ZStack {
            ILAtmosphereBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    ILScreenHeroHeader(kicker: "Rewards", title: "Reward themes", systemIcon: "paintpalette.fill") {
                        EmptyView()
                    }
                    Text("Unlock accent palettes with trophy points. Your choice updates the highlight on the main tab bar and other cyan accents.")
                        .font(.subheadline)
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(ILTheme.amber)
                        Text("\(store.trophyPointsTotal) trophy points")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ILTheme.backgroundTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    ILRewardThemesPickerSection(toast: $toast)
                }
                .padding(16)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .ilTracksProfileNavigationDepth(router)
    }
}

/// Shared theme list — also embedded in Statistics.
struct ILRewardThemesPickerSection: View {
    @Binding var toast: String?
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose a palette")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(ILTheme.textPrimaryOnDark)
            Text("Locked themes show the points needed. Arctic is always available.")
                .font(.caption)
                .foregroundStyle(ILTheme.textMutedOnDark)
            VStack(spacing: 8) {
                ForEach(ILAppRewardTheme.allCases, id: \.rawValue) { th in
                    let unlocked = th.isUnlocked(trophyPoints: store.trophyPointsTotal)
                    let active = store.activeRewardTheme == th
                    Button {
                        guard unlocked else { return }
                        store.setRewardTheme(th)
                        toast = "Theme: \(th.displayName)"
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(th.displayName)
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(unlocked ? ILTheme.textPrimaryOnDark : ILTheme.textMutedOnDark)
                                Text(unlocked ? (th.minimumPoints == 0 ? "Always available" : "Unlocked at \(th.minimumPoints)+ pts") : "Locked — \(th.minimumPoints)+ pts")
                                    .font(.caption2)
                                    .foregroundStyle(ILTheme.textMutedOnDark)
                            }
                            Spacer()
                            if active {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(ILTheme.semanticSuccess)
                            } else if unlocked {
                                Image(systemName: "circle")
                                    .foregroundStyle(ILTheme.divider)
                            } else {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(ILTheme.textMutedOnDark)
                            }
                        }
                        .padding(12)
                        .background(ILTheme.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(active ? accent.light.opacity(0.45) : ILTheme.divider, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!unlocked)
                }
            }
        }
        .padding(.top, 8)
    }
}
