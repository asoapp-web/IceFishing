import Combine
import SwiftUI
import UIKit

// MARK: - Marked Catch field size (for spawn / move, not UIScreen guesses)

private struct MCFieldSizePref: PreferenceKey {
    static var defaultValue: CGSize = CGSize(width: 320, height: 260)
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let n = nextValue()
        if n.width > 1, n.height > 1 { value = n }
    }
}

// MARK: - Hub

struct ILGamesHubView: View {
    /// When `true`, hub lives in the main tab bar (no modal close button).
    var embeddedInTab: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.ilRewardAccent) private var accent
    @EnvironmentObject private var store: ILPersistenceStore
    @EnvironmentObject private var router: ILAppRouter
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                ILAtmosphereBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Nav row
                        HStack {
                            if !embeddedInTab {
                                Button {
                                    dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                                        .frame(width: 34, height: 34)
                                        .background(ILTheme.backgroundTertiary)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(ILTheme.divider, lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                            Spacer()
                            HStack(spacing: 6) {
                                Image(systemName: "trophy.fill")
                                    .foregroundStyle(ILTheme.amber)
                                Text("\(store.trophyPointsTotal) pts")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(ILTheme.textPrimaryOnDark)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(ILTheme.backgroundTertiary)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(ILTheme.amber.opacity(0.3), lineWidth: 1))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, embeddedInTab ? 16 : 8)

                        if embeddedInTab {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(ILTheme.amber)
                                Text("Tip: orange dots on tabs mean you haven’t opened that section today. Hit all six for a small trophy bonus.")
                                    .font(.system(.caption, design: .rounded, weight: .medium))
                                    .foregroundStyle(ILTheme.textSecondaryOnDark)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(ILTheme.backgroundTertiary)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(ILTheme.amber.opacity(0.25), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                        }

                        // How to play (one screen per game)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("How to play")
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                .foregroundStyle(ILTheme.textMutedOnDark)
                                .padding(.horizontal, 4)
                            HStack(spacing: 10) {
                                guideLaunchButton(
                                    title: "Ice Pull",
                                    icon: "arrow.up.to.line.compact",
                                    tint: accent.light
                                ) { path.append("pullGuide") }
                                guideLaunchButton(
                                    title: "Marked Catch",
                                    icon: "fish.fill",
                                    tint: ILTheme.amber
                                ) { path.append("markedGuide") }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Title
                        VStack(spacing: 8) {
                            Text("Mini-Games")
                                .font(.ilDisplay(30))
                                .foregroundStyle(ILTheme.textPrimaryOnDark)
                            TierBadge(tier: store.currentTrophyTier)
                        }

                        // Game cards
                        VStack(spacing: 14) {
                            HubGameCard(
                                title: "Ice Pull",
                                subtitle: "Hold to reel — keep tension in the sweet spot",
                                icon: "arrow.up.to.line.compact",
                                accentColor: accent.light,
                                high: store.pullHighScore,
                                played: store.pullGamesPlayed
                            ) {
                                path.append("pull")
                            }
                            HubGameCard(
                                title: "Marked Catch",
                                subtitle: "Tap targets only — speed ramps up as time runs out",
                                icon: "fish.fill",
                                accentColor: ILTheme.amber,
                                high: store.markedHighScore,
                                played: store.markedGamesPlayed
                            ) {
                                path.append("marked")
                            }
                        }
                        .padding(.horizontal, 20)

                        // Trophy progress
                        TrophyProgressCard(store: store)
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationDestination(for: String.self) { dest in
                switch dest {
                case "pullGuide":
                    ILIcePullGuideView { path.removeLast() }
                case "markedGuide":
                    ILMarkedCatchGuideView { path.removeLast() }
                case "pull":
                    ILPullGameView { path.removeLast() }
                        .environmentObject(store)
                case "marked":
                    ILMarkedCatchGameView { path.removeLast() }
                        .environmentObject(store)
                default:
                    EmptyView()
                }
            }
        }
        // Single, reliable place to sync tabBarHidden with NavigationPath depth.
        .onChange(of: path.count) { _, count in
            router.tabBarHidden = count > 0
        }
        .onAppear {
            router.tabBarHidden = path.count > 0
        }
        .onDisappear {
            router.tabBarHidden = false
        }
    }

    private func guideLaunchButton(title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(ILTheme.textPrimaryOnDark)
                Text("Open guide")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(ILTheme.textMutedOnDark)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(ILTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(tint.opacity(0.35), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct TierBadge: View {
    let tier: ILTrophyTier
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: tier.symbolName)
            Text(tier.displayName)
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(ILTheme.amber)
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Capsule().fill(ILTheme.amber.opacity(0.18)))
        .overlay(Capsule().stroke(ILTheme.amber.opacity(0.35), lineWidth: 1))
    }
}

private struct HubGameCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let high: Int
    let played: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(accentColor)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                        .lineLimit(2)
                    HStack(spacing: 10) {
                        Label(high > 0 ? "\(high)" : "—", systemImage: "star.fill")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(ILTheme.amber)
                        Text("Played: \(played)")
                            .font(.caption2)
                            .foregroundStyle(ILTheme.textMutedOnDark)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ILTheme.textMutedOnDark)
            }
            .padding(16)
            .background(ILTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [accentColor.opacity(0.30), accentColor.opacity(0.08)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.30), radius: 10, y: 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct TrophyProgressCard: View {
    @ObservedObject var store: ILPersistenceStore

    var body: some View {
        let tier = store.currentTrophyTier
        let next = tier.next
        let cur  = store.trophyPointsTotal
        let prev = tier.minimumPoints
        let frac: CGFloat = {
            guard let n = next else { return 1 }
            let span = CGFloat(n.minimumPoints - prev)
            guard span > 0 else { return 1 }
            return min(1, max(0, CGFloat(cur - prev) / span))
        }()

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Trophy Progress")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(ILTheme.textPrimaryOnDark)
                Spacer()
                if let n = next {
                    Text("\(cur) / \(n.minimumPoints)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(ILTheme.textMutedOnDark)
                } else {
                    Text("Max tier!")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(ILTheme.amber)
                }
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(ILTheme.backgroundTertiary)
                    Capsule()
                        .fill(LinearGradient(colors: [ILTheme.amber, ILTheme.amberDark], startPoint: .leading, endPoint: .trailing))
                        .frame(width: g.size.width * frac)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: frac)
                }
            }
            .frame(height: 8)
            if let n = next {
                Text("Next: \(n.displayName)")
                    .font(.caption2)
                    .foregroundStyle(ILTheme.textMutedOnDark)
            }
        }
        .padding(16)
        .background(ILTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ILTheme.divider, lineWidth: 1)
        )
    }
}

// MARK: - Pull Game

struct ILPullGameView: View {
    let onBack: () -> Void
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum Phase { case waiting, bite, reeling, ended }

    @State private var phase: Phase = .waiting
    @State private var tension: CGFloat = 0        // 0..1
    @State private var progress: CGFloat = 0       // 0..1 (reeling progress)
    @State private var fishSizeMul = 1
    @State private var waitTimer: Timer?
    @State private var biteDeadline: Date?
    @State private var biteFlash = false
    @State private var isHolding = false           // user is holding the REEL button
    @State private var resistancePhase: CGFloat = 0
    @State private var redAccum: CGFloat = 0
    @State private var blueAccum: CGFloat = 0
    @State private var lastScore = 0
    @State private var lastOutcome: PullOutcome = .missed
    @State private var showResult = false
    @State private var resultNewHigh = false
    @State private var lineWobble: CGFloat = 0
    @State private var fishDepth: CGFloat = 1.0    // 1=deep, 0=caught
    @State private var hookBounce = false
    @State private var pullCompleting = false      // avoids double success tick

    private enum PullOutcome { case success(mul: Int), lineBreak, escaped, missed }

    // Tension sweet spot: [0.35 … 0.65]
    private var inGreen: Bool { tension > 0.35 && tension < 0.65 }
    private var inRed: Bool   { tension > 0.78 }
    private var inBlue: Bool  { tension < 0.18 }

    private var tensionColor: Color {
        if inRed   { return .red }
        if inBlue  { return accent.light.opacity(0.6) }
        if inGreen { return ILTheme.semanticSuccess }
        return ILTheme.amber
    }

    var body: some View {
        ZStack {
            ILAtmosphereBackground()
            VStack(spacing: 0) {
                navBar
                gameArea
                bottomControls
                    .padding(.bottom, 32)
            }
            if showResult {
                pullResultOverlay
            }
        }
        .navigationBarHidden(true)
        .onAppear { startNewRound() }
        .onDisappear { waitTimer?.invalidate() }
        .onReceive(Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()) { _ in
            tick()
        }
    }

    // MARK: Nav

    private var navBar: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Games")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ILTheme.textSecondaryOnDark)
            }
            .buttonStyle(.plain)
            Spacer()
            Text("Ice Pull")
                .font(.ilDisplay(18))
                .foregroundStyle(ILTheme.textPrimaryOnDark)
            Spacer()
            Text("Best: \(store.pullHighScore)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(ILTheme.textMutedOnDark)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: Game area

    private var gameArea: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let holeSize: CGFloat = 110
            let holeY: CGFloat = h * 0.22
            let lineTopY  = holeY + holeSize * 0.5
            let lineBottomY = h * 0.72
            let span = max(40, lineBottomY - lineTopY)
            let lift = 1 - fishDepth
            let fishY = lineBottomY - span * lift + 6

            ZStack {
                // Ice surface
                IceSurfaceDecor(width: w)
                    .frame(width: w, height: holeY - 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                // Water below ice
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                accent.dark.opacity(0.20),
                                ILTheme.backgroundTertiary.opacity(0.60),
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(height: h - holeY + 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                // Fishing line
                if phase == .reeling || phase == .bite {
                    FishingLine(
                        topX: w / 2,
                        topY: lineTopY,
                        bottomX: w / 2 + lineWobble,
                        bottomY: fishY,
                        color: tensionColor
                    )
                    .animation(reduceMotion ? .none : .easeInOut(duration: 0.05), value: lineWobble)
                }

                // Ice hole
                IceHoleView(size: holeSize, flash: biteFlash, phase: phase)
                    .position(x: w / 2, y: holeY)

                // Fish sprite (underwater)
                if phase == .reeling || phase == .bite {
                    FishUnderwater(sizeMul: fishSizeMul, depth: fishDepth, bounce: hookBounce)
                        .position(
                            x: w / 2 + lineWobble,
                            y: fishY
                        )
                        .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7), value: fishDepth)
                }

                // Status text
                VStack(spacing: 6) {
                    Spacer()
                    phaseStatusView
                }
                .frame(width: w, height: h)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var phaseStatusView: some View {
        switch phase {
        case .waiting:
            VStack(spacing: 4) {
                Text("Line in the water…")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(ILTheme.textSecondaryOnDark)
                Text("Wait for a bite")
                    .font(.caption)
                    .foregroundStyle(ILTheme.textMutedOnDark)
            }
            .padding(.bottom, 24)
        case .bite:
            Text("🎣 Fish on! HOLD REEL!")
                .font(.system(.headline, design: .rounded, weight: .heavy))
                .foregroundStyle(accent.light)
                .shadow(color: accent.mid.opacity(0.8), radius: 8)
                .scaleEffect(biteFlash ? 1.1 : 1.0)
                .animation(reduceMotion ? .none : .easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: biteFlash)
                .padding(.bottom, 24)
        case .reeling:
            HStack(spacing: 16) {
                TensionZoneLabel(color: tensionColor, label: inGreen ? "Sweet spot!" : inRed ? "Too tight!" : inBlue ? "Too slack!" : "Keep steady")
            }
            .padding(.bottom, 24)
        case .ended:
            EmptyView()
        }
    }

    // MARK: Bottom controls

    private var bottomControls: some View {
        HStack(spacing: 20) {
            // Tension bar (+ zone labels)
            TensionBarView(tension: tension)
                .frame(width: 88, height: 188)

            Spacer()

            // Reel button
            ReelButtonView(isHolding: $isHolding, enabled: phase == .bite || phase == .reeling)
                .frame(width: 120, height: 120)
                .onChange(of: isHolding) { _, holding in
                    if holding, phase == .bite {
                        phase = .reeling
                    }
                }

            Spacer()

            // Progress bar (how close to surface)
            ProgressBarVertical(progress: progress, label: "Depth")
                .frame(width: 40, height: 180)
        }
        .padding(.horizontal, 32)
    }

    // MARK: Tick

    private func tick() {
        // Tension driven by hold button
        if isHolding {
            tension = min(1, tension + 0.025)
        } else {
            tension = max(0, tension - 0.040)
        }

        guard phase == .reeling else {
            if phase == .bite, let d = biteDeadline, Date() > d {
                endRound(.missed)
            }
            return
        }
        if pullCompleting { return }

        // Wobble the line
        resistancePhase += 0.12
        let wobble = sin(resistancePhase) * 8
        withAnimation(.none) { lineWobble = wobble }

        // Bigger fish = slightly slower reel (still reachable in green)
        let sizePenalty = CGFloat(max(1, fishSizeMul))
        let greenGain: CGFloat = 0.024 / sizePenalty

        if inGreen {
            progress = min(1, progress + greenGain)
            fishDepth = max(0, 1 - progress)
            redAccum  = max(0, redAccum - 0.06)
            blueAccum = max(0, blueAccum - 0.06)
            if Int.random(in: 0..<10) == 0 { ILHaptics.light() }
        } else if inRed {
            redAccum += 0.06
            progress = max(0, progress - 0.004)
            fishDepth = max(0, 1 - progress)
            if redAccum > 1.6 { endRound(.lineBreak) }
        } else if inBlue {
            blueAccum += 0.05
            progress = max(0, progress - 0.008)
            fishDepth = max(0, 1 - progress)
            if blueAccum > 2.0 { endRound(.escaped) }
        } else {
            progress = max(0, progress - 0.002)
            fishDepth = max(0, 1 - progress)
            redAccum  = max(0, redAccum - 0.03)
            blueAccum = max(0, blueAccum - 0.03)
        }

        if progress >= 1, !pullCompleting {
            pullCompleting = true
            hookBounce = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                endRound(.success(mul: fishSizeMul))
            }
        }
    }

    // MARK: Round management

    private func startNewRound() {
        let r = Int.random(in: 0..<100)
        fishSizeMul = r < 50 ? 1 : (r < 85 ? 2 : 3)
        phase = .waiting
        progress = 0
        tension = 0
        fishDepth = 1.0
        lineWobble = 0
        redAccum = 0
        blueAccum = 0
        resistancePhase = 0
        hookBounce = false
        pullCompleting = false
        scheduleNextBite()
    }

    private func scheduleNextBite() {
        waitTimer?.invalidate()
        let delay = Double.random(in: 2.5...6.0)
        waitTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            guard phase == .waiting else { return }
            phase = .bite
            biteDeadline = Date().addingTimeInterval(2.0)
            withAnimation { biteFlash = true }
            ILHaptics.heavy()
        }
    }

    private func endRound(_ o: PullOutcome) {
        guard phase != .ended else { return }
        phase = .ended
        pullCompleting = false
        waitTimer?.invalidate()
        isHolding = false
        var score = 0
        switch o {
        case .success(let m): score = 100 * m; ILHaptics.success()
        case .lineBreak:       score = 10;     ILHaptics.error()
        case .escaped:         score = 10;     ILHaptics.error()
        case .missed:          score = 0;      ILHaptics.error()
        }
        lastOutcome = o
        lastScore = score
        let prev = store.pullHighScore
        store.applyPullRound(score: score)
        resultNewHigh = score > prev
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            showResult = true
        }
    }

    // MARK: Result overlay

    private var pullResultOverlay: some View {
        let title: String
        let sub: String
        switch lastOutcome {
        case .success(let m):
            title = "Caught! 🎉"
            sub = "\(m == 1 ? "Small" : m == 2 ? "Medium" : "Large") fish"
        case .lineBreak: title = "Line Snapped! 💥"; sub = "Too much tension"
        case .escaped:   title = "Fish Escaped! 🐟"; sub = "Too little tension"
        case .missed:    title = "Missed! 😅";       sub = "Reaction too slow"
        }
        return ILGameResultOverlay(
            title: title, subtitle: sub,
            score: lastScore, newHigh: resultNewHigh,
            accentColor: accent.light,
            onAgain: {
                showResult = false
                biteFlash = false
                startNewRound()
            },
            onHub: onBack
        )
        .environmentObject(store)
    }
}

// MARK: - Pull sub-views

private struct IceSurfaceDecor: View {
    let width: CGFloat
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#C5E0F0")?.opacity(0.85) ?? ILTheme.iceLight.opacity(0.85),
                            Color(hex: "#A8C8E0")?.opacity(0.70) ?? ILTheme.iceLight.opacity(0.70),
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            // Ice crack lines
            Canvas { ctx, size in
                let lines: [(CGPoint, CGPoint)] = [
                    (CGPoint(x: size.width * 0.1, y: size.height * 0.3), CGPoint(x: size.width * 0.35, y: size.height * 0.7)),
                    (CGPoint(x: size.width * 0.6, y: size.height * 0.1), CGPoint(x: size.width * 0.8, y: size.height * 0.85)),
                    (CGPoint(x: size.width * 0.05, y: size.height * 0.6), CGPoint(x: size.width * 0.25, y: size.height * 0.95)),
                    (CGPoint(x: size.width * 0.75, y: size.height * 0.4), CGPoint(x: size.width * 0.95, y: size.height * 0.8)),
                ]
                for (a, b) in lines {
                    var path = Path()
                    path.move(to: a)
                    path.addLine(to: b)
                    ctx.stroke(path, with: .color(Color.white.opacity(0.45)), lineWidth: 0.8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct IceHoleView: View {
    let size: CGFloat
    let flash: Bool
    let phase: ILPullGameView.Phase
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var holePhase: String {
        switch phase {
        case .waiting:  return "waiting"
        case .bite:     return "bite"
        case .reeling:  return "reel"
        case .ended:    return "ended"
        }
    }

    var body: some View {
        ZStack {
            // Outer ice ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#90BDD4")?.opacity(0.6) ?? accent.dark.opacity(0.6),
                            Color(hex: "#B8D8EC")?.opacity(0.5) ?? ILTheme.iceLight.opacity(0.5),
                        ],
                        center: .center, startRadius: size * 0.4, endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)
            // Water inside hole
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            accent.dark.opacity(0.80),
                            ILTheme.background.opacity(0.95),
                        ],
                        center: .center, startRadius: 10, endRadius: size * 0.48
                    )
                )
                .frame(width: size * 0.76, height: size * 0.76)
                .overlay(
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [accent.light.opacity(flash ? 0.9 : 0.4), accent.mid.opacity(0.2)],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: flash ? 2.5 : 1.5
                        )
                        .scaleEffect(flash ? 1.05 : 1.0)
                        .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: flash)
                )
        }
    }
}

private struct FishingLine: View {
    let topX: CGFloat
    let topY: CGFloat
    let bottomX: CGFloat
    let bottomY: CGFloat
    let color: Color

    var body: some View {
        Canvas { ctx, _ in
            var path = Path()
            path.move(to: CGPoint(x: topX, y: topY))
            path.addLine(to: CGPoint(x: bottomX, y: bottomY))
            ctx.stroke(path, with: .color(color.opacity(0.8)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
        }
        .allowsHitTesting(false)
    }
}

private struct FishUnderwater: View {
    let sizeMul: Int
    let depth: CGFloat
    let bounce: Bool
    @Environment(\.ilRewardAccent) private var accent

    private var fishSize: CGFloat { CGFloat(sizeMul) * 12 + 18 }

    var body: some View {
        Image(systemName: "fish.fill")
            .font(.system(size: fishSize, weight: .semibold))
            .foregroundStyle(
                LinearGradient(
                    colors: [accent.light, accent.dark],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .shadow(color: accent.mid.opacity(0.6), radius: 6)
            .scaleEffect(bounce ? 1.3 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: bounce)
            .opacity(0.6 + depth * 0.4)
    }
}

private struct TensionBarView: View {
    let tension: CGFloat
    @Environment(\.ilRewardAccent) private var accent
    private let barHeight: CGFloat = 168

    private var color: Color {
        if tension > 0.78 { return .red }
        if tension < 0.18 { return accent.light.opacity(0.85) }
        if tension > 0.35 && tension < 0.65 { return ILTheme.semanticSuccess }
        return ILTheme.amber
    }

    var body: some View {
        VStack(spacing: 6) {
            Text("TENSION")
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundStyle(ILTheme.textMutedOnDark)

            HStack(alignment: .top, spacing: 8) {
                GeometryReader { g in
                    let h = g.size.height
                    let zoneBottom = h * (1 - 0.65)
                    let zoneTop = h * (1 - 0.35)
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(ILTheme.backgroundTertiary)
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(ILTheme.semanticSuccess.opacity(0.18))
                            .frame(height: zoneTop - zoneBottom)
                            .offset(y: -(h - zoneTop))
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.55), color],
                                    startPoint: .bottom, endPoint: .top
                                )
                            )
                            .frame(height: max(2, h * tension))
                        Circle()
                            .fill(.white)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(color, lineWidth: 2))
                            .shadow(color: color.opacity(0.6), radius: 4)
                            .offset(y: -(h * tension - 6))
                    }
                }
                .frame(width: 34, height: barHeight)

                VStack(alignment: .leading, spacing: 0) {
                    Text("High")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.red.opacity(0.9))
                    Spacer()
                    Text("Sweet")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(ILTheme.semanticSuccess)
                    Spacer()
                    Text("Low")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(accent.light)
                }
                .frame(width: 44, height: barHeight)
            }
            .frame(height: barHeight)
        }
    }
}

private struct ReelButtonView: View {
    @Binding var isHolding: Bool
    let enabled: Bool
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let label = enabled ? (isHolding ? "REELING" : "HOLD\nTO REEL") : "WAITING…"

        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: enabled
                            ? [accent.light.opacity(isHolding ? 1.0 : 0.7), accent.dark]
                            : [ILTheme.backgroundTertiary, ILTheme.backgroundSecondary],
                        center: .center, startRadius: 5, endRadius: 55
                    )
                )
                .shadow(
                    color: enabled ? accent.mid.opacity(isHolding ? 0.7 : 0.3) : .clear,
                    radius: isHolding ? 18 : 8
                )
                .scaleEffect(isHolding ? 0.94 : 1.0)
                .animation(reduceMotion ? .none : .spring(response: 0.25, dampingFraction: 0.7), value: isHolding)

            Text(label)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(enabled ? ILTheme.background : ILTheme.textMutedOnDark)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard enabled, !isHolding else { return }
                    isHolding = true
                    ILHaptics.light()
                }
                .onEnded { _ in
                    isHolding = false
                }
        )
        .disabled(!enabled)
    }
}

private struct ProgressBarVertical: View {
    let progress: CGFloat
    let label: String
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        VStack(spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundStyle(ILTheme.textMutedOnDark)
            GeometryReader { g in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(ILTheme.backgroundTertiary)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [accent.dark, accent.light],
                                startPoint: .bottom, endPoint: .top
                            )
                        )
                        .frame(height: g.size.height * progress)
                        .animation(.easeOut(duration: 0.04), value: progress)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text("\(Int(progress * 100))%")
                .font(.system(size: 9, weight: .semibold).monospacedDigit())
                .foregroundStyle(ILTheme.textMutedOnDark)
        }
    }
}

private struct TensionZoneLabel: View {
    let color: Color
    let label: String
    var body: some View {
        Text(label)
            .font(.system(.subheadline, design: .rounded, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.4), lineWidth: 1))
    }
}

// MARK: - Game guides

private struct ILIcePullGuideView: View {
    let onBack: () -> Void
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        ZStack {
            ILAtmosphereBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Ice Pull")
                        .font(.ilDisplay(28))
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                    Text("Full manual — read once, then play. Everything below is intentionally detailed so you never guess what the UI is doing.")
                        .font(.subheadline)
                        .foregroundStyle(ILTheme.textMutedOnDark)
                        .fixedSize(horizontal: false, vertical: true)
                    guideCard(
                        title: "What you’re trying to do",
                        body: "Each round is a short fight under the ice. A fish takes the bait, you reel it up through the hole, and the game scores you on control — not on spam-tapping. Think “steady hands” more than “fast hands.”"
                    )
                    guideCard(
                        title: "The three phases (mental model)",
                        body: "Waiting: line is down, nothing to press yet — you’re watching for a bite. Bite: the fish is hooked; the UI will shout that it’s time to act. Reeling: you’re holding REEL, managing tension, and filling the landing progress until the catch completes or you fail."
                    )
                    guideCard(
                        title: "Where to look on screen",
                        body: "Top area shows the ice hole and water. Middle has status text that matches the phase. Bottom has the big REEL control, a tension column, and a depth/progress column. Tension is the main skill check; depth/progress tells you how close you are to finishing the reel."
                    )
                    guideCard(
                        title: "Waiting phase — don’t burn yourself out",
                        body: "You can’t reel early. Use the pause to relax your thumb. When the bite triggers, you’ll switch instantly — the worst habit is hovering with full pressure on REEL before anything happens; it doesn’t help and it adds stress."
                    )
                    guideCard(
                        title: "Bite phase — commit quickly",
                        body: "When the game tells you the fish is on, start holding REEL as soon as you read the cue. Hesitation often dumps you into bad tension on the first frame of the fight. You can always adjust after you’re reeling; you can’t recover lost seconds at the start."
                    )
                    guideCard(
                        title: "How REEL works (hold, not tap)",
                        body: "Press and hold the large button to pull. Release to pause the pull. Short taps usually hurt you: tension jolts, progress stalls, and you’re more likely to spike into red or blue. Smooth holds with tiny breath-style releases work better."
                    )
                    guideCard(
                        title: "Tension bar — green is home",
                        body: "Green is the safe band where you want to live. Here the line is tight enough to move the fish but not so tight that you risk a snap. If you’re green most of the time during reeling, you’re playing correctly even if the fish feels “slow.”"
                    )
                    guideCard(
                        title: "Red zone — too much pull",
                        body: "Red means you’re overpowering the line. Staying high red builds punishment over time and can end the round with a break. If you see red, ease off immediately — micro-release, not a full panic drop unless you’re about to snap."
                    )
                    guideCard(
                        title: "Blue / cold side — too little pull",
                        body: "The loose end of the bar means slack. Too much slack lets the fish shake the hook or stall your progress. If you’re blue, add gentle pressure back — usually a slightly longer hold rather than a smash."
                    )
                    guideCard(
                        title: "Micro-adjustments beat zig-zags",
                        body: "Good players “breathe” the button: a little less pressure when tension climbs, a little more when it sags. Bad players slam between extremes — that creates spikes that trip red/blue logic and wastes progress ticks."
                    )
                    guideCard(
                        title: "Progress / landing meter",
                        body: "While tension is healthy, your reel progress advances. If you’re constantly in danger zones, progress slows or stalls depending on the exact round logic — treat visible progress as feedback that your tension discipline is working."
                    )
                    guideCard(
                        title: "Fish depth animation (what it means)",
                        body: "The fish graphic moving upward is a visual mirror of progress, not a separate button to chase. Don’t chase the art with frantic tapping; chase the green tension band while holding REEL in calm pulses."
                    )
                    guideCard(
                        title: "Failure outcomes (so they’re not a mystery)",
                        body: "You can miss entirely if you don’t respond to the bite window. During reeling you can lose to line break (typically red abuse), fish escape (often slack / blue neglect), or other round-end states shown in the result overlay — read the subtitle text after each round; it’s the real tutor."
                    )
                    guideCard(
                        title: "Scoring intuition",
                        body: "Higher scores generally come from cleaner reels: fewer seconds in red/blue, steadier green time, and completing catches without dropping the sequence. If your score is low but you “won,” you probably yo-yo’d tension too hard."
                    )
                    guideCard(
                        title: "Warm-up routine (30 seconds)",
                        body: "Before grinding for high score: play one round focusing only on staying green, ignoring the number. Round two, add “smooth holds only.” Round three, play for score. This builds muscle memory faster than restarting after every frustration spike."
                    )
                    guideCard(
                        title: "Common mistakes checklist",
                        body: "• Tapping REEL instead of holding.\n• Ignoring tension until you’re already red.\n• Releasing completely when slightly high instead of easing.\n• Staring at the fish sprite instead of the tension column.\n• Starting late on the bite callout."
                    )
                    guideCard(
                        title: "After the round",
                        body: "The overlay shows outcome, points, and whether you set a new personal best. Use “Again” to repeat the learning loop; use “Games” to return to the hub when you’re done. Trophy points feed your overall progression — check Profile → Statistics if you care about totals."
                    )
                }
                .padding(20)
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Games")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(accent.light)
                }
            }
        }
    }

    private func guideCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(accent.light)
            Text(body)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(ILTheme.textSecondaryOnDark)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(ILTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(ILTheme.divider, lineWidth: 1)
        )
    }
}

private struct ILMarkedCatchGuideView: View {
    let onBack: () -> Void
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        ZStack {
            ILAtmosphereBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Marked Catch")
                        .font(.ilDisplay(28))
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                    Text("Extended guide — how to read the field, what each fish type means, and how streak scoring behaves.")
                        .font(.subheadline)
                        .foregroundStyle(ILTheme.textMutedOnDark)
                        .fixedSize(horizontal: false, vertical: true)
                    guideCard(
                        title: "Objective in one breath",
                        body: "You have 60 seconds, three hearts, and a moving school of silhouettes. Tap only the legitimate targets for the species named at the top. Everything else is either a decoy or a forbidden “marked” fish. Speed increases as time runs down — plan for escalation, not for a calm start-to-finish."
                    )
                    guideCard(
                        title: "The HUD row (read left → right)",
                        body: "Fish icon + “Target:” + species name defines legality for taps. Hearts are lives — you lose one per mistake. The yellow number is score — it jumps more as streak multipliers wake up. The timer in the nav bar is merciless; there is no pause, so prioritize accuracy over showy reflexes."
                    )
                    guideCard(
                        title: "Three fish kinds (this is the whole game)",
                        body: "Target: the species you’re allowed to tap, oriented correctly for its swim direction — these are your points. Other / wrong-way: same palette family but swimming the wrong way relative to the round’s rules — visually tempting, always wrong. Marked: carries a faint × — never tap, even if everything else about it “looks” right."
                    )
                    guideCard(
                        title: "Why facing direction matters",
                        body: "The game encodes decoys as wrong-way motion so you can’t autopilot on color alone. When you scan a fish, check motion + silhouette together: does it look like it belongs in the current lane of travel? If your gut says “same fish but backwards,” treat it as toxic bait."
                    )
                    guideCard(
                        title: "Marked fish — almost invisible on purpose",
                        body: "The × is deliberately subtle so expert play is about attention, not UI clutter. If you’re losing hearts “randomly,” slow down and scan the top-right of each sprite cluster before tapping. Marked fish are a skill tax on players who spam taps."
                    )
                    guideCard(
                        title: "Tap discipline (thumb strategy)",
                        body: "Use deliberate single taps on the body of the fish button, not drags across the canvas. Mis-taps often come from swiping between two nearby circles — if two overlap in time, you may hit the wrong collider. Pause a split-second when the screen is crowded."
                    )
                    guideCard(
                        title: "Spawn pressure & crowding",
                        body: "More fish on screen means higher cognitive load but also more correct targets per second if you stay calm. When density spikes, switch strategy: narrow your vision to the target strip (vertical band) where your species usually swims and ignore outer distractions."
                    )
                    guideCard(
                        title: "Difficulty ramp over the minute",
                        body: "Fish move faster and spawn logic tightens as seconds drop. Early game is for building streak safely; late game is for protecting hearts. If you enter the last 15 seconds with one heart, play like a coward — only 100% obvious targets."
                    )
                    guideCard(
                        title: "Streak and multipliers (how score explodes)",
                        body: "Correct taps in a row build a streak. After enough consecutive hits, multipliers kick in (you’ll see streak UI when it’s relevant). One mistake resets the streak to zero — so a single greedy tap on a decoy costs both a heart and the mathematical upside of your run."
                    )
                    guideCard(
                        title: "Hearts — what costs one",
                        body: "Tapping a decoy/wrong-way fish, tapping a marked fish, or tapping anything that isn’t a valid target for the named species. Running out ends the round immediately and locks in your score for that attempt."
                    )
                    guideCard(
                        title: "What “wrong fish” feedback means",
                        body: "On-screen popups label mistakes differently for marked vs other wrong taps — use that text as training wheels until your eyes do the job alone. If you keep seeing one class of error, drill that class only for a round (e.g., only practice spotting wrong-way silhouettes)."
                    )
                    guideCard(
                        title: "Accuracy > APM",
                        body: "This isn’t a rhythm game. Higher actions per minute with sloppy verification will tank your hearts before your score climbs. Aim for a calm cadence: identify → confirm facing/mark → tap once → reacquire the next target."
                    )
                    guideCard(
                        title: "Warm-up drill (60s plan)",
                        body: "First 20s: only tap when you can say the species name out loud. Middle 20s: focus purely on facing. Last 20s: play for score while keeping the rule stack in your head. Rotate the emphasis each run so you don’t develop a blind spot."
                    )
                    guideCard(
                        title: "Common failure patterns",
                        body: "• Autopilot tapping when the target species changes — re-read the header every few seconds.\n• Ignoring faint × because you’re locked on color.\n• Chasing fish near the edges where silhouettes overlap.\n• Panic tapping when the timer flashes low — freeze, breathe, one correct tap beats three gambles."
                    )
                    guideCard(
                        title: "High scores & persistence",
                        body: "Your best run is saved for the hub card and trophy progression. If you’re hunting a new record, play shorter sessions with breaks — eye fatigue creates exactly the misreads this mode punishes."
                    )
                    guideCard(
                        title: "When you’re ready",
                        body: "Go back to Games, hit Marked Catch, and treat the first run as practice even if you know the rules — the muscle memory layer still needs real spawns. Good luck, and don’t feed the marked fish."
                    )
                }
                .padding(20)
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Games")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(accent.light)
                }
            }
        }
    }

    private func guideCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(ILTheme.amber)
            Text(body)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(ILTheme.textSecondaryOnDark)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(ILTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(ILTheme.divider, lineWidth: 1)
        )
    }
}

// MARK: - Marked Catch Game

struct ILMarkedCatchGameView: View {
    let onBack: () -> Void
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent

    @State private var timeLeft   = 60
    @State private var lives      = 3
    @State private var score      = 0
    @State private var streak     = 0
    @State private var targetId   = ""
    @State private var fish: [MCFish] = []
    @State private var gameTimer: Timer?
    @State private var spawnTimer: Timer?
    @State private var moveTimer:  Timer?
    @State private var showResult  = false
    @State private var roundOver   = false
    @State private var newHigh     = false
    @State private var lastTap: CGPoint? = nil
    @State private var tapEffects: [TapEffect] = []
    @State private var fieldSize: CGSize = CGSize(
        width: UIScreen.main.bounds.width - 40,
        height: min(340, UIScreen.main.bounds.height * 0.38)
    )

    struct MCFish: Identifiable {
        let id   = UUID()
        var x    : CGFloat
        var y    : CGFloat
        var vx   : CGFloat  // horizontal speed
        var kind : Kind
        var scale: CGFloat  // random size

        enum Kind { case target, other, marked }
    }

    private struct TapEffect: Identifiable {
        let id   = UUID()
        var pt   : CGPoint
        var text : String
        var color: Color
    }

    var body: some View {
        ZStack {
            ILAtmosphereBackground()
            VStack(spacing: 0) {
                mcNavBar
                targetLabel
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                gameCanvas
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            tapEffectLayer
            if showResult { markedResultOverlay }
        }
        .navigationBarHidden(true)
        .onAppear { startMarkedGame() }
        .onDisappear { stopAllTimers() }
    }

    // MARK: Sub-views

    private var mcNavBar: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Games")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ILTheme.textSecondaryOnDark)
            }
            .buttonStyle(.plain)
            Spacer()
            Text("Marked Catch")
                .font(.ilDisplay(18))
                .foregroundStyle(ILTheme.textPrimaryOnDark)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                Text("\(timeLeft)")
                    .font(.system(.subheadline, design: .rounded, weight: .bold).monospacedDigit())
            }
            .foregroundStyle(timeLeft <= 10 ? ILTheme.tertiaryRed : ILTheme.textSecondaryOnDark)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var targetLabel: some View {
        let content = ILBundleContentService.shared
        let name = content.species(by: targetId)?.commonName ?? "—"
        return HStack(spacing: 12) {
            Image(systemName: "fish.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(accent.light)
            Text("Target:")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(ILTheme.textSecondaryOnDark)
            Text(name)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(accent.light)
            Spacer()
            // Lives
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart")
                        .font(.system(size: 15))
                        .foregroundStyle(i < lives ? ILTheme.tertiaryRed : ILTheme.backgroundTertiary)
                }
            }
            // Score
            Text("\(score)")
                .font(.system(.headline, design: .rounded, weight: .bold).monospacedDigit())
                .foregroundStyle(ILTheme.amber)
        }
        .padding(12)
        .background(ILTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(ILTheme.divider, lineWidth: 1)
        )
    }

    private var gameCanvas: some View {
        GeometryReader { geo in
            ZStack {
                // Underwater gradient
                LinearGradient(
                    colors: [
                        ILTheme.backgroundSecondary.opacity(0.75),
                        accent.dark.opacity(0.22),
                        ILTheme.background.opacity(0.5),
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal, 16)

                // Fish
                ForEach(fish) { f in
                    FishButton(fish: f) { handleTap(f, in: geo.size) }
                }

                // Streak indicator
                if streak >= 3 {
                    StreakBadge(streak: streak)
                        .position(x: geo.size.width / 2, y: 40)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .preference(key: MCFieldSizePref.self, value: geo.size)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 12)
        .onPreferenceChange(MCFieldSizePref.self) { fieldSize = $0 }
    }

    private var tapEffectLayer: some View {
        ZStack {
            ForEach(tapEffects) { e in
                Text(e.text)
                    .font(.system(.headline, design: .rounded, weight: .heavy))
                    .foregroundStyle(e.color)
                    .position(e.pt)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 1.4).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var markedResultOverlay: some View {
        ILGameResultOverlay(
            title: "Round Over",
            subtitle: "Streak: \(streak)",
            score: score,
            newHigh: newHigh,
            accentColor: ILTheme.amber,
            onAgain: {
                showResult = false
                resetMarkedGame()
            },
            onHub: onBack
        )
        .environmentObject(store)
    }

    // MARK: Logic

    private func startMarkedGame() {
        pickTarget()
        gameTimer  = Timer.scheduledTimer(withTimeInterval: 1, repeats: true)  { _ in countdown() }
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in spawnFish() }
        moveTimer  = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { _ in moveFish() }
    }

    private func stopAllTimers() {
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        moveTimer?.invalidate()
    }

    private func countdown() {
        if timeLeft > 0 { timeLeft -= 1 } else { finish() }
    }

    private func pickTarget() {
        let all = ILBundleContentService.shared.species
        targetId = all.randomElement()?.id ?? ""
    }

    private var speedMultiplier: CGFloat {
        let elapsed = CGFloat(60 - timeLeft)
        return 1.0 + min(1.35, elapsed / 45.0 * 1.1)
    }

    private func spawnFish() {
        guard fish.count < 9, !roundOver else { return }
        let w = max(100, fieldSize.width - 20)
        let h = max(100, fieldSize.height - 24)
        let roll = Double.random(in: 0...1)
        let kind: MCFish.Kind
        if roll < 0.22 { kind = .marked }
        else if roll < 0.48 { kind = .other }
        else { kind = .target }

        let goRight = Bool.random()
        // vx = pixels moved per moveFish tick (~25/s); ramps with difficulty
        let base = CGFloat.random(in: 3.2...5.8) * speedMultiplier
        let vx = base * (goRight ? 1 : -1)
        let startX = goRight ? -40.0 : w + 40.0
        let f = MCFish(
            x: startX,
            y: CGFloat.random(in: 52...(h - 52)),
            vx: vx,
            kind: kind,
            scale: CGFloat.random(in: 0.88...1.28)
        )
        fish.append(f)
    }

    private func moveFish() {
        guard !roundOver else { return }
        let w = max(100, fieldSize.width - 20)
        fish = fish.compactMap { f in
            var f = f
            f.x += f.vx
            if f.x < -72 || f.x > w + 72 { return nil }
            return f
        }
    }

    private func handleTap(_ f: MCFish, in size: CGSize) {
        guard !roundOver else { return }
        switch f.kind {
        case .marked, .other:
            lives -= 1
            streak = 0
            ILHaptics.error()
            let msg = f.kind == .marked ? "Marked" : "Wrong fish"
            let col = f.kind == .marked ? ILTheme.iceLight.opacity(0.55) : ILTheme.amber.opacity(0.85)
            addTapEffect(at: CGPoint(x: f.x, y: f.y), text: msg, color: col)
            fish.removeAll { $0.id == f.id }
            if lives <= 0 { finish() }

        case .target:
            let mult = streakMult
            let pts  = 20 * mult
            score  += pts
            streak += 1
            ILHaptics.light()
            addTapEffect(at: CGPoint(x: f.x, y: f.y), text: mult > 1 ? "+\(pts) ×\(mult)!" : "+\(pts)", color: accent.light)
            fish.removeAll { $0.id == f.id }
        }
    }

    private var streakMult: Int {
        switch streak {
        case 0..<5:  return 1
        case 5..<10: return 2
        case 10..<20: return 3
        default:     return 5
        }
    }

    private func addTapEffect(at pt: CGPoint, text: String, color: Color) {
        let e = TapEffect(pt: pt, text: text, color: color)
        withAnimation(.spring(response: 0.3)) {
            tapEffects.append(e)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeOut(duration: 0.3)) {
                tapEffects.removeAll { $0.id == e.id }
            }
        }
    }

    private func finish() {
        guard !roundOver else { return }
        roundOver = true
        stopAllTimers()
        let prev = store.markedHighScore
        store.applyMarkedRound(score: score, bestStreak: streak)
        newHigh = score > prev
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showResult = true
        }
    }

    private func resetMarkedGame() {
        roundOver = false; newHigh = false; showResult = false
        timeLeft = 60; lives = 3; score = 0; streak = 0; fish = []
        tapEffects = []
        pickTarget()
        startMarkedGame()
    }
}

private struct FishButton: View {
    let fish: ILMarkedCatchGameView.MCFish
    let onTap: () -> Void
    @Environment(\.ilRewardAccent) private var accent
    @State private var pressed = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.2)) { pressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { pressed = false }
            onTap()
        } label: {
            let tint = accent.light
            // SF Symbol fish faces left. vx > 0 → swimming right → correct fish should face right (−1 on X).
            let facesRightScale: CGFloat = fish.vx > 0 ? -1 : 1
            let wrongWayScale: CGFloat = fish.vx > 0 ? 1 : -1
            let iconScale: CGFloat = {
                switch fish.kind {
                case .target: return facesRightScale
                case .other: return wrongWayScale
                case .marked: return facesRightScale
                }
            }()
            let isCorrectTarget = fish.kind == .target
            ZStack {
                if !isCorrectTarget {
                    Circle()
                        .fill(tint.opacity(0.12))
                        .frame(width: 58, height: 58)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1.5)
                        )
                }
                Image(systemName: "fish.fill")
                    .font(.system(size: isCorrectTarget ? 34 : 28, weight: .semibold))
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(isCorrectTarget ? tint : tint.opacity(0.72))
                    .scaleX(iconScale)
                if fish.kind == .marked {
                    Image(systemName: "xmark")
                        .font(.system(size: 7, weight: .semibold))
                        .foregroundStyle(ILTheme.iceLight.opacity(0.28))
                        .offset(x: 13, y: -11)
                }
            }
            .frame(width: 58, height: 58)
            .contentShape(Rectangle())
            .scaleEffect(fish.scale * (pressed ? 0.85 : 1.0))
            .shadow(color: isCorrectTarget ? tint.opacity(0.35) : tint.opacity(0.25), radius: pressed ? 2 : (isCorrectTarget ? 8 : 6))
        }
        .buttonStyle(.plain)
        .position(x: fish.x, y: fish.y)
    }
}

private struct StreakBadge: View {
    let streak: Int
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
            Text("×\(streakMult) Streak \(streak)")
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(ILTheme.amber)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(ILTheme.backgroundTertiary)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(ILTheme.amber.opacity(0.4), lineWidth: 1))
        .shadow(color: ILTheme.amber.opacity(0.3), radius: 8)
    }

    private var streakMult: Int {
        switch streak {
        case 0..<5:  return 1
        case 5..<10: return 2
        case 10..<20: return 3
        default:     return 5
        }
    }
}

// MARK: - Shared Result Overlay

struct ILGameResultOverlay: View {
    let title: String
    let subtitle: String
    let score: Int
    let newHigh: Bool
    var accentColor: Color = ILTheme.cyanLight
    let onAgain: () -> Void
    let onHub: () -> Void
    @EnvironmentObject private var store: ILPersistenceStore

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture { }  // block pass-through

            VStack(spacing: 0) {
                // Accent bar
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(LinearGradient(colors: [accentColor, accentColor.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
                    .frame(height: 4)

                VStack(spacing: 18) {
                    VStack(spacing: 8) {
                        Text(title)
                            .font(.system(.title, design: .rounded, weight: .heavy))
                            .foregroundStyle(accentColor)
                        if !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(ILTheme.textSecondaryOnDark)
                        }
                    }
                    .padding(.top, 24)

                    // Score
                    VStack(spacing: 4) {
                        Text("\(score)")
                            .font(.system(size: 52, weight: .heavy, design: .rounded).monospacedDigit())
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                        Text("points")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(ILTheme.textMutedOnDark)
                    }

                    if newHigh {
                        Label("New High Score!", systemImage: "star.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(ILTheme.amber)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(ILTheme.amber.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(ILTheme.amber)
                        Text("Total Trophy Points: \(store.trophyPointsTotal)")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ILTheme.textSecondaryOnDark)

                    VStack(spacing: 12) {
                        Button(action: onAgain) {
                            Text("Play Again")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(ILTheme.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(colors: [accentColor, accentColor.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        Button(action: onHub) {
                            Text("Back to Games")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(ILTheme.textSecondaryOnDark)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 28)
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(ILTheme.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [accentColor.opacity(0.35), ILTheme.divider],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 30, y: 15)
            )
            .padding(.horizontal, 28)
            .transition(.scale(scale: 0.85).combined(with: .opacity))
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: true)
    }
}

// MARK: - View helpers

private extension View {
    func scaleX(_ sx: CGFloat) -> some View {
        scaleEffect(CGSize(width: sx, height: 1))
    }
}
