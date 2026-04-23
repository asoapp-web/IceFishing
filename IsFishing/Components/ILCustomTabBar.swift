import SwiftUI

private struct ILTabItem: Identifiable {
    let id: Int
    let title: String
    let symbol: String
}

struct ILCustomTabBar: View {
    @Binding var selected: Int
    @Namespace private var capsuleNS
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @EnvironmentObject private var store: ILPersistenceStore
    @EnvironmentObject private var router: ILAppRouter

    private let items: [ILTabItem] = [
        ILTabItem(id: 0, title: "Guide",    symbol: "book.fill"),
        ILTabItem(id: 1, title: "Species",  symbol: "fish.fill"),
        ILTabItem(id: 2, title: "Map",      symbol: "map.fill"),
        ILTabItem(id: 3, title: "Sessions", symbol: "clock.fill"),
        ILTabItem(id: 4, title: "Games",    symbol: "gamecontroller.fill"),
        ILTabItem(id: 5, title: "Profile",  symbol: "person.crop.circle.fill"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                tabButton(item)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .background(barBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(sessionRecordingBarTrim)
        .shadow(color: .black.opacity(0.50), radius: 24, y: 12)
        .padding(.horizontal, 14)
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private var sessionRecordingBarTrim: some View {
        let trip = store.activeRewardTheme.accentTriplet
        if router.sessionEditorActive {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .trim(from: 0, to: 0.42)
                .stroke(
                    AngularGradient(
                        colors: [
                            trip.0,
                            ILTheme.amber,
                            trip.0.opacity(0.15),
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .modifier(SessionBarSweep(reduceMotion: reduceMotion))
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private var barBackground: some View {
        let trip = store.activeRewardTheme.accentTriplet
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(ILTheme.backgroundElevated.opacity(reduceTransparency ? 1 : 0.92))
            if !reduceTransparency {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.55))
            }
            
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.22),
                            Color.white.opacity(0.04),
                            Color.clear,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.1
                )
                .padding(.horizontal, 0.5)
                .padding(.top, 0.5)
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            trip.0.opacity(0.38),
                            trip.1.opacity(0.10),
                            trip.0.opacity(0.20),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.15
                )
        }
    }

    private func tabButton(_ item: ILTabItem) -> some View {
        let isSelected = selected == item.id
        let trip = store.activeRewardTheme.accentTriplet
        let selGrad = LinearGradient(
            colors: [trip.0, trip.1],
            startPoint: .top,
            endPoint: .bottom
        )
        let nudgeOn = store.dailyTabNudgeActive(for: item.id) && !isSelected
        return Button {
            ILHaptics.light()
            if selected != item.id {
                store.registerMainTabVisit(item.id)
            }
            withAnimation(reduceMotion ? .default : .spring(response: 0.32, dampingFraction: 0.78)) {
                selected = item.id
            }
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        if isSelected {
                            
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            trip.0.opacity(0.25),
                                            trip.1.opacity(0.15),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .matchedGeometryEffect(id: "sel", in: capsuleNS)
                                .frame(width: 48, height: 34)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(trip.0.opacity(0.45), lineWidth: 1)
                                )
                                .shadow(color: trip.0.opacity(0.4), radius: 12, x: 0, y: 4)
                                .modifier(TabGlowPulse(reduceMotion: reduceMotion))
                        }
                        
                        Image(systemName: item.symbol)
                            .font(.system(size: 19, weight: isSelected ? .semibold : .regular))
                            .foregroundStyle(
                                isSelected
                                    ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: [ILTheme.frostWhite, trip.0, trip.1],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    : AnyShapeStyle(ILTheme.tabBarLabelInactive)
                            )
                            .shadow(color: isSelected ? trip.0.opacity(0.6) : .clear, radius: isSelected ? 8 : 0, x: 0, y: 0)
                            .modifier(TabIconPulse(active: isSelected, reduceMotion: reduceMotion))
                            .modifier(SessionsTabTimerPulse(
                                active: item.id == 3 && router.sessionEditorActive,
                                reduceMotion: reduceMotion
                            ))
                            .frame(width: 48, height: 34)
                            .ilFloat(range: isSelected ? 2 : 0, duration: 2)
                    }
                    
                    if nudgeOn {
                        TabNudgeBadge(tabIndex: item.id, reduceMotion: reduceMotion)
                            .offset(x: 6, y: -4)
                    }
                }
                
                Text(item.title)
                    .font(.system(size: 9, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(
                        isSelected 
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [ILTheme.frostWhite.opacity(0.95), trip.0],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            : AnyShapeStyle(ILTheme.tabBarLabelInactive)
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}



private struct SessionBarSweep: ViewModifier {
    let reduceMotion: Bool
    @State private var spin: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(Double(spin)))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                    spin = 360
                }
            }
    }
}

private struct SessionsTabTimerPulse: ViewModifier {
    let active: Bool
    let reduceMotion: Bool
    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .overlay {
                if active {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [ILTheme.cyanLight, ILTheme.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 40, height: 40)
                        .scaleEffect(pulse ? 1.3 : 0.9)
                        .opacity(pulse ? 0.2 : 0.9)
                }
            }
            .onAppear { sync() }
            .onChange(of: active) { _, _ in sync() }
    }

    private func sync() {
        guard active, !reduceMotion else {
            pulse = false
            return
        }
        pulse = false
        withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }
}



private struct TabGlowPulse: ViewModifier {
    let reduceMotion: Bool
    @State private var glow: CGFloat = 0.5
    
    func body(content: Content) -> some View {
        content
            .opacity(0.85 + glow * 0.15)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glow = 1
                }
            }
    }
}



private struct TabNudgeBadge: View {
    let tabIndex: Int
    let reduceMotion: Bool

    var body: some View {
        Group {
            switch tabIndex {
            case 0: BookNudge(reduceMotion: reduceMotion)
            case 1: FishNudge(reduceMotion: reduceMotion)
            case 2: MapNudge(reduceMotion: reduceMotion)
            case 3: ClockNudge(reduceMotion: reduceMotion)
            case 4: GamesNudge(reduceMotion: reduceMotion)
            default: ProfileNudge(reduceMotion: reduceMotion)
            }
        }
        .frame(width: 14, height: 14)
    }
}

private struct BookNudge: View {
    let reduceMotion: Bool
    @Environment(\.ilRewardAccent) private var accent
    @State private var flip: CGFloat = 0
    @State private var glow: CGFloat = 0
    var body: some View {
        ZStack {
            Circle()
                .fill(accent.light.opacity(0.2))
                .frame(width: 16, height: 16)
                .blur(radius: 4)
            Image(systemName: "book.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ILTheme.frostWhite, accent.light],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .rotationEffect(.degrees(Double(flip * 12)))
                .shadow(color: accent.light.opacity(0.5 + glow * 0.5), radius: 4, x: 0, y: 0)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                flip = 1
            }
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                glow = 1
            }
        }
    }
}

private struct FishNudge: View {
    let reduceMotion: Bool
    @Environment(\.ilRewardAccent) private var accent
    @State private var wiggle: CGFloat = 0
    @State private var glow: CGFloat = 0
    var body: some View {
        ZStack {
            Circle()
                .fill(accent.light.opacity(0.2))
                .frame(width: 16, height: 16)
                .blur(radius: 4)
            Image(systemName: "fish.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ILTheme.frostWhite, accent.light],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .offset(x: wiggle * 3)
                .shadow(color: accent.light.opacity(0.5 + glow * 0.5), radius: 4, x: 0, y: 0)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                wiggle = 1
            }
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                glow = 1
            }
        }
    }
}

private struct MapNudge: View {
    let reduceMotion: Bool
    @Environment(\.ilRewardAccent) private var accent
    @State private var bounce: CGFloat = 0
    @State private var glow: CGFloat = 0
    var body: some View {
        ZStack {
            Circle()
                .fill(accent.light.opacity(0.2))
                .frame(width: 16, height: 16)
                .blur(radius: 4)
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ILTheme.frostWhite, accent.light],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .offset(y: bounce * -2)
                .shadow(color: accent.light.opacity(0.5 + glow * 0.5), radius: 4, x: 0, y: 0)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.65).repeatForever(autoreverses: true)) {
                bounce = 1
            }
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                glow = 1
            }
        }
    }
}

private struct ClockNudge: View {
    let reduceMotion: Bool
    @Environment(\.ilRewardAccent) private var accent
    @State private var tick: Double = 0
    @State private var glow: CGFloat = 0
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [accent.light, accent.mid],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 13, height: 13)
                .shadow(color: accent.light.opacity(0.5 + glow * 0.5), radius: 4, x: 0, y: 0)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [accent.light, ILTheme.frostWhite],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1.5, height: 4.5)
                .offset(y: -1.8)
                .rotationEffect(.degrees(tick))
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                tick = 360
            }
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                glow = 1
            }
        }
    }
}

private struct GamesNudge: View {
    let reduceMotion: Bool
    @Environment(\.ilRewardAccent) private var accent
    @State private var glow = false
    @State private var pulse: CGFloat = 0
    var body: some View {
        ZStack {
            Circle()
                .fill(accent.light.opacity(0.2 + pulse * 0.1))
                .frame(width: 16, height: 16)
                .blur(radius: 4)
            Image(systemName: "sparkle")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ILTheme.frostWhite, accent.light, accent.mid],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(glow ? 1.15 : 0.88)
                .shadow(color: accent.light.opacity(0.6), radius: 4 + pulse * 4, x: 0, y: 0)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                glow = true
            }
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                pulse = 1
            }
        }
    }
}

private struct ProfileNudge: View {
    let reduceMotion: Bool
    @Environment(\.ilRewardAccent) private var accent
    @State private var pulse = false
    @State private var glow: CGFloat = 0
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accent.light.opacity(0.4), accent.light.opacity(0.1)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 10, height: 10)
                .blur(radius: 2)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [ILTheme.frostWhite, accent.light],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 8, height: 8)
                .shadow(color: accent.light.opacity(0.5 + glow * 0.5), radius: 4, x: 0, y: 0)
        }
        .opacity(pulse ? 1 : 0.5)
        .scaleEffect(pulse ? 1.1 : 0.9)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulse = true
            }
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                glow = 1
            }
        }
    }
}

private struct TabIconPulse: ViewModifier {
    let active: Bool
    let reduceMotion: Bool
    @State private var bump = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(bump && active ? 1.14 : 1.0)
            .onChange(of: active) { _, new in
                guard new, !reduceMotion else { return }
                withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) { bump = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) { bump = false }
                }
            }
    }
}
