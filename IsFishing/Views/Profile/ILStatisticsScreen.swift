import SwiftUI

struct ILStatisticsScreen: View {
    @Binding var toast: String?
    @EnvironmentObject private var router: ILAppRouter
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var rewardAccent
    @State private var period: ILSessionPeriod = .all

    private let content = ILBundleContentService.shared

    private var sessionsFiltered: [ILSession] {
        let cal = Calendar.current
        let now = Date()
        return store.sessions.filter { s in
            guard let d = ILDateFormatting.date(from: s.date) else { return true }
            switch period {
            case .all: return true
            case .month:
                return cal.isDate(d, equalTo: now, toGranularity: .month)
                    && cal.isDate(d, equalTo: now, toGranularity: .year)
            case .week:
                guard let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else { return true }
                return d >= start
            }
        }
    }

    private var fishFiltered: Int {
        sessionsFiltered.reduce(0) { partial, s in
            partial + s.catchEntries.reduce(0) { $0 + $1.quantity }
        }
    }

    private var longestSession: Int {
        sessionsFiltered.compactMap(\.durationMinutes).max() ?? 0
    }

    var body: some View {
        ZStack {
            ILAtmosphereBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    ILScreenHeroHeader(kicker: "Your journey", title: "Statistics", systemIcon: "chart.bar.fill") {
                        EmptyView()
                    }
                    
                    HStack(spacing: 0) {
                        ForEach(ILSessionPeriod.allCases, id: \.self) { p in
                            Button { withAnimation(.easeInOut(duration: 0.18)) { period = p } } label: {
                                Text(p.rawValue)
                                    .font(.system(size: 13, weight: period == p ? .semibold : .medium, design: .rounded))
                                    .foregroundStyle(period == p ? rewardAccent.light : ILTheme.textMutedOnDark)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 9)
                                    .background(period == p ? RoundedRectangle(cornerRadius: 10, style: .continuous).fill(rewardAccent.light.opacity(0.15)) : nil)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(4)
                    .background(ILTheme.backgroundTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(ILTheme.divider, lineWidth: 1))
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        statCell(title: "Total Sessions", value: "\(sessionsFiltered.count)", symbol: "clock.fill", tint: false, interactive: true) {
                            router.selectedTab = 3
                        }
                        statCell(title: "Total Fish Caught", value: "\(fishFiltered)", symbol: "fish.fill", tint: false, interactive: false) {}
                        statCell(title: "Total Spots", value: "\(store.spots.count)", symbol: "mappin.and.ellipse", tint: false, interactive: true) {
                            router.selectedTab = 2
                        }
                        statCell(title: "Articles Read", value: "\(store.readArticleIds.count)/\(content.guideArticles.count)", symbol: "book.fill", tint: false, interactive: true) {
                            router.selectedTab = 0
                        }
                        statCell(title: "Species Explored", value: "\(store.exploredSpeciesIds.count)/\(content.species.count)", symbol: "magnifyingglass", tint: false, interactive: true) {
                            router.selectedTab = 1
                        }
                        statCell(title: "Games Played", value: "\(store.pullGamesPlayed + store.markedGamesPlayed)", symbol: "gamecontroller.fill", tint: false, interactive: false) {}
                        statCell(title: "Pull High Score", value: "\(store.pullHighScore)", symbol: "arrow.up.circle.fill", tint: true, interactive: false) {}
                        statCell(title: "Marked Catch High Score", value: "\(store.markedHighScore)", symbol: "target", tint: true, interactive: false) {}
                        statCell(title: "Trophy Points", value: "\(store.trophyPointsTotal)", symbol: "trophy.fill", tint: false, interactive: false) {}
                        statCell(title: "Trophy Tier", value: store.currentTrophyTier.displayName, symbol: "crown.fill", tint: false, interactive: false) {}
                        statCell(title: "Total Notes", value: "\(store.notes.count)", symbol: "note.text", tint: false, interactive: false) {}
                        statCell(title: "Longest Session", value: longestSession > 0 ? "\(longestSession)m" : "—", symbol: "hourglass", tint: false, interactive: false) {}
                    }
                    ILRewardThemesPickerSection(toast: $toast)
                    if sessionsFiltered.isEmpty && store.sessions.isEmpty {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Start exploring Is Fishing to build your stats!")
                        }
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                        .padding(.top, 8)
                    }
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .ilTracksProfileNavigationDepth(router)
    }

    private func statCell(title: String, value: String, symbol: String, tint: Bool, interactive: Bool, action: @escaping () -> Void) -> some View {
        let cellTint = tint ? rewardAccent.mid : rewardAccent.light
        let card = VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(cellTint.opacity(0.15))
                        .frame(width: 34, height: 34)
                    Image(systemName: symbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(cellTint)
                }
                Spacer()
                if interactive {
                    Image(systemName: "arrow.right.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(ILTheme.textMutedOnDark)
                }
            }
            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(ILTheme.textPrimaryOnDark)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(title)
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(ILTheme.textMutedOnDark)
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ilCard()

        return Group {
            if interactive {
                Button(action: action) { card }.buttonStyle(.plain)
            } else {
                card
            }
        }
    }
}
