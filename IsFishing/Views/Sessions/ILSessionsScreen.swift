import SwiftUI

enum ILSessionPeriod: String, CaseIterable {
    case all = "All Time"
    case month = "This Month"
    case week = "This Week"
}

struct ILSessionsScreen: View {
    @Binding var toast: String?
    @EnvironmentObject private var router: ILAppRouter
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent
    @State private var period: ILSessionPeriod = .all
    @State private var editorSession: ILSession?
    @State private var creating = false

    private let content = ILBundleContentService.shared

    private var filtered: [ILSession] {
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
        }.sorted { a, b in
            (ILDateFormatting.date(from: a.date) ?? .distantPast) > (ILDateFormatting.date(from: b.date) ?? .distantPast)
        }
    }

    private var totalFish: Int {
        store.sessions.reduce(0) { partial, s in
            partial + s.catchEntries.reduce(0) { $0 + $1.quantity }
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ILAtmosphereBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sessions")
                            .font(.ilDisplay(32))
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                        Text("\(store.sessions.count) trips logged")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(ILTheme.textMutedOnDark)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                    statsRow
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)

                    periodPicker
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                    if filtered.isEmpty {
                        ILEmptyState(icon: "calendar.badge.plus", message: "No sessions yet. Tap + to log your first ice fishing trip.")
                            .frame(minHeight: 320)
                            .padding(.horizontal, 20)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(filtered) { session in
                                sessionCard(session)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.bottom, 120)
            }

            // FAB
            Button {
                creating = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(colors: [accent.light, accent.mid], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(Circle())
                    .shadow(color: accent.mid.opacity(0.45), radius: 14, y: 5)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 20)
            .padding(.bottom, 100)
        }
        .sheet(isPresented: $creating) {
            ILSessionEditorView(mode: .create, toast: $toast)
                .environmentObject(store)
        }
        .sheet(item: $editorSession) { s in
            ILSessionEditorView(mode: .edit(s), toast: $toast)
                .environmentObject(store)
        }
        .onChange(of: creating) { _, v in
            router.sessionEditorActive = v || editorSession != nil
        }
        .onChange(of: editorSession != nil) { _, v in
            router.sessionEditorActive = v || creating
        }
    }

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(ILSessionPeriod.allCases, id: \.self) { p in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) { period = p }
                } label: {
                    Text(p.rawValue)
                        .font(.system(size: 13, weight: period == p ? .semibold : .medium, design: .rounded))
                        .foregroundStyle(period == p ? accent.light : ILTheme.textMutedOnDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            period == p
                                ? RoundedRectangle(cornerRadius: 10, style: .continuous).fill(accent.light.opacity(0.15))
                                : nil
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(ILTheme.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(ILTheme.divider, lineWidth: 1)
        )
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            miniStat(icon: "calendar", title: "Sessions", value: "\(store.sessions.count)")
            miniStat(icon: "fish.fill", title: "Fish", value: "\(totalFish)")
            miniStat(icon: "clock.fill", title: "Last Trip", value: lastTripString)
        }
    }

    private var lastTripString: String {
        guard let s = store.sessions.max(by: { a, b in
            (ILDateFormatting.date(from: a.date) ?? .distantPast) < (ILDateFormatting.date(from: b.date) ?? .distantPast)
        }), let d = ILDateFormatting.date(from: s.date) else { return "—" }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: d)
    }

    private func miniStat(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(accent.light.opacity(0.7))
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(ILTheme.textPrimaryOnDark)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(title)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(ILTheme.textMutedOnDark)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ILTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(ILTheme.divider, lineWidth: 1)
        )
    }

    private func sessionCard(_ s: ILSession) -> some View {
        Button { editorSession = s } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(ILDateFormatting.displayDate(fromISO: s.date))
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                                .foregroundStyle(accent.light.opacity(0.6))
                            if let sid = s.spotId, let sp = store.spots.first(where: { $0.id == sid }) {
                                Text(sp.name)
                            } else {
                                Text("No spot linked")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        if let m = s.durationMinutes {
                            HStack(spacing: 3) {
                                Image(systemName: "clock")
                                    .font(.system(size: 11))
                                Text(formatDuration(m))
                            }
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(ILTheme.textMutedOnDark)
                        }
                        if !s.photoIds.isEmpty {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(ILTheme.textMutedOnDark)
                        }
                    }
                }
                let n = s.catchEntries.reduce(0) { $0 + $1.quantity }
                HStack(spacing: 8) {
                    HStack(spacing: 5) {
                        Image(systemName: "fish.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(accent.light)
                        Text("\(n) fish")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(accent.light)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(accent.light.opacity(0.12)))
                    let tags = s.catchEntries.compactMap { e -> String? in
                        if let sid = e.speciesId { return content.species(by: sid)?.commonName }
                        return e.customSpeciesName
                    }
                    ForEach(Array(Set(tags)).prefix(2), id: \.self) { t in
                        Text(t)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(ILTheme.textSecondaryOnDark)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(ILTheme.backgroundTertiary))
                            .overlay(Capsule().stroke(ILTheme.divider, lineWidth: 0.5))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(ILTheme.textMutedOnDark)
                }
            }
            .padding(14)
            .background(ILTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [accent.light.opacity(0.18), ILTheme.divider],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }

    private func formatDuration(_ m: Int) -> String {
        let h = m / 60
        let mm = m % 60
        if h > 0 { return "\(h)h \(mm)m" }
        return "\(mm)m"
    }
}

