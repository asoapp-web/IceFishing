import SwiftUI

/// Large, animated hero regions — each onboarding slide gets a distinct motion language.
enum ILOnboardingHeroKind: Int, CaseIterable {
    case welcome
    case learn
    case map
    case ready
}

struct ILOnboardingHero: View {
    let kind: ILOnboardingHeroKind
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: reduceMotion)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            ZStack {
                switch kind {
                case .welcome:
                    FishSchoolHero(t: t, accent: accent, reduceMotion: reduceMotion)
                case .learn:
                    BookStackHero(t: t, accent: accent, reduceMotion: reduceMotion)
                case .map:
                    MapPinHero(t: t, accent: accent, reduceMotion: reduceMotion)
                case .ready:
                    ReadyHero(t: t, accent: accent, reduceMotion: reduceMotion)
                }
            }
            .frame(height: 220)
            .frame(maxWidth: .infinity)
        }
    }
}


private struct FishSchoolHero: View {
    let t: TimeInterval
    let accent: ILRewardAccent
    let reduceMotion: Bool
    
    var body: some View {
        ZStack {
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            accent.light.opacity(0.2),
                            accent.mid.opacity(0.08),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 40,
                        endRadius: 130
                    )
                )
                .frame(width: 260, height: 260)
                .blur(radius: 30)

            
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [
                            accent.light.opacity(0.6),
                            accent.mid.opacity(0.3),
                            accent.light.opacity(0.5),
                        ],
                        center: .center
                    ),
                    lineWidth: 4
                )
                .frame(width: 126, height: 126)
                .scaleEffect(reduceMotion ? 1 : 1 + 0.02 * sin(t * 0.7))
                .shadow(color: accent.light.opacity(0.4), radius: 10)

            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ILTheme.background.opacity(0.3),
                            ILTheme.background.opacity(0.85),
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 60
                    )
                )
                .frame(width: 110, height: 110)

            
            FishSwarm(t: t, accent: accent, reduceMotion: reduceMotion)
            
            
            Bubbles(t: t)
        }
    }
}

private struct FishSwarm: View {
    let t: TimeInterval
    let accent: ILRewardAccent
    let reduceMotion: Bool
    
    var body: some View {
        ForEach(0..<7, id: \.self) { i in
            AnimatedFish(index: i, t: t, accent: accent, reduceMotion: reduceMotion)
        }
    }
}

private struct AnimatedFish: View {
    let index: Int
    let t: TimeInterval
    let accent: ILRewardAccent
    let reduceMotion: Bool
    
    private var seed: Double { Double(index) * 1.37 }
    private var baseX: CGFloat { CGFloat(index - 3) * 40 }
    private var wobble: CGFloat { reduceMotion ? 0 : CGFloat(sin(t * 1.2 + seed) * 12) }
    private var bob: CGFloat { reduceMotion ? 0 : CGFloat(cos(t * 0.9 + seed * 0.5) * 8) }
    private var fishScale: CGFloat { 1 + 0.1 * CGFloat(sin(t + seed)) }
    private var rotation: Double { reduceMotion ? 0 : sin(t * 0.8 + seed) * 10 }
    private var fontSize: CGFloat { 24 + CGFloat(index % 3) * 4 }
    private var opacity1: Double { 0.95 - Double(index) * 0.06 }
    
    var body: some View {
        Image(systemName: "fish.fill")
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        accent.light.opacity(opacity1),
                        accent.mid.opacity(0.8),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: accent.mid.opacity(0.5), radius: 6)
            .offset(x: baseX + wobble, y: bob + CGFloat((index % 2) * 8))
            .rotationEffect(.degrees(rotation))
            .scaleEffect(fishScale)
    }
}

private struct Bubbles: View {
    let t: TimeInterval
    
    var body: some View {
        ForEach(0..<5) { i in
            AnimatedBubble(index: i, t: t)
        }
    }
}

private struct AnimatedBubble: View {
    let index: Int
    let t: TimeInterval
    
    private var y: CGFloat {
        let idx = Double(index)
        return -60 + CGFloat(sin(t * 2 + idx) * 40)
    }
    private var x: CGFloat {
        let idx = Double(index)
        return CGFloat(index - 2) * 25 + CGFloat(cos(t * 1.5 + idx) * 15)
    }
    private var scale: CGFloat {
        let idx = Double(index)
        return 0.5 + CGFloat(sin(t * 3 + idx) * 0.3)
    }
    
    var body: some View {
        Circle()
            .fill(ILTheme.iceLight.opacity(0.4))
            .frame(width: 8, height: 8)
            .offset(x: x, y: y)
            .scaleEffect(scale)
    }
}


private struct BookStackHero: View {
    let t: TimeInterval
    let accent: ILRewardAccent
    let reduceMotion: Bool
    
    var body: some View {
        ZStack {
            
            Circle()
                .fill(accent.light.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 40)

            
            FloatingPages(t: t, accent: accent, reduceMotion: reduceMotion)

            
            CentralBookIcon(accent: accent)
        }
    }
}

private struct FloatingPages: View {
    let t: TimeInterval
    let accent: ILRewardAccent
    let reduceMotion: Bool
    
    var body: some View {
        ForEach(0..<5, id: \.self) { i in
            FloatingPage(index: i, t: t, accent: accent, reduceMotion: reduceMotion)
        }
    }
}

private struct FloatingPage: View {
    let index: Int
    let t: TimeInterval
    let accent: ILRewardAccent
    let reduceMotion: Bool
    
    private var rotation: Double {
        let idx = Double(index)
        if reduceMotion { return idx * -3 }
        return sin(t * 0.4 + idx * 0.8) * 6 + idx * -3
    }
    private var yOff: CGFloat {
        let idx = Double(index)
        return CGFloat(index) * -10 + CGFloat(sin(t * 0.6 + idx) * 5)
    }
    private var xOff: CGFloat { CGFloat(cos(t * 0.5 + Double(index)) * 3) }
    private var pageWidth: CGFloat { 124 - CGFloat(index) * 5 }
    private var pageHeight: CGFloat { 154 - CGFloat(index) * 4 }
    private var opacity1: Double { 0.95 - Double(index) * 0.1 }
    private var opacity2: Double { 0.9 - Double(index) * 0.1 }
    private var strokeOpacity: Double { 0.3 - Double(index) * 0.04 }
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.2))
                .frame(width: pageWidth, height: pageHeight)
                .offset(x: 4, y: 4)
            
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ILTheme.backgroundElevated.opacity(opacity1),
                            ILTheme.backgroundSecondary.opacity(opacity2),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: pageWidth, height: pageHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    accent.light.opacity(strokeOpacity),
                                    accent.mid.opacity(0.1),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.25), radius: 10, y: 5)
        }
        .offset(x: xOff, y: yOff)
        .rotationEffect(.degrees(rotation))
    }
}

private struct CentralBookIcon: View {
    let accent: ILRewardAccent
    
    var body: some View {
        ZStack {
            Circle()
                .fill(accent.light.opacity(0.2))
                .frame(width: 80, height: 80)
                .blur(radius: 20)
            
            Image(systemName: "text.book.closed.fill")
                .font(.system(size: 42, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            ILTheme.frostWhite,
                            accent.light,
                            accent.mid,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: accent.light.opacity(0.5), radius: 15)
                .offset(y: -20)
                .ilFloat(range: 5, duration: 2.5)
        }
    }
}


private struct MapPinHero: View {
    let t: TimeInterval
    let accent: ILRewardAccent
    let reduceMotion: Bool
    
    var body: some View {
        let drop: CGFloat = reduceMotion ? 0 : max(0, 25 - CGFloat((sin(t * 1.6) + 1) * 12))
        let pulse: CGFloat = reduceMotion ? 1.0 : 0.7 + 0.3 * CGFloat(sin(t * 2.2))

        return ZStack {
            
            MapBase(accent: accent)

            
            GridLines(accent: accent)

            
            LocationDots(t: t, accent: accent)

            
            MapPin(t: t, accent: accent, drop: drop, pulse: pulse)
        }
    }
}

private struct MapBase: View {
    let accent: ILRewardAccent
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        ILTheme.backgroundSecondary,
                        ILTheme.backgroundTertiary.opacity(0.95),
                        ILTheme.backgroundSecondary,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 210, height: 140)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                accent.light.opacity(0.35),
                                accent.mid.opacity(0.15),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: .black.opacity(0.35), radius: 15, y: 8)
    }
}

private struct GridLines: View {
    let accent: ILRewardAccent
    
    var body: some View {
        Path { p in
            for gx in stride(from: -85, through: 85, by: 28) {
                p.move(to: CGPoint(x: 105 + CGFloat(gx), y: 15))
                p.addLine(to: CGPoint(x: 105 + CGFloat(gx), y: 125))
            }
            for gy in stride(from: -50, through: 50, by: 28) {
                p.move(to: CGPoint(x: 25, y: 70 + CGFloat(gy)))
                p.addLine(to: CGPoint(x: 185, y: 70 + CGFloat(gy)))
            }
        }
        .stroke(
            LinearGradient(
                colors: [accent.light.opacity(0.15), accent.mid.opacity(0.08)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            lineWidth: 0.8
        )
    }
}

private struct LocationDots: View {
    let t: TimeInterval
    let accent: ILRewardAccent
    
    var body: some View {
        ForEach(0..<3) { i in
            LocationDot(index: i, t: t, accent: accent)
        }
    }
}

private struct LocationDot: View {
    let index: Int
    let t: TimeInterval
    let accent: ILRewardAccent
    
    private var x: CGFloat {
        let idx = Double(index)
        return 50 + CGFloat(index) * 55 + CGFloat(sin(t * 0.8 + idx) * 5)
    }
    private var y: CGFloat {
        let idx = Double(index)
        return 50 + CGFloat(index % 2) * 35 + CGFloat(cos(t * 0.6 + idx) * 5)
    }
    private var opacity: Double {
        let idx = Double(index)
        return 0.3 + sin(t * 2 + idx) * 0.2
    }
    
    var body: some View {
        Circle()
            .fill(accent.light.opacity(opacity))
            .frame(width: 8, height: 8)
            .position(x: x, y: y)
    }
}

private struct MapPin: View {
    let t: TimeInterval
    let accent: ILRewardAccent
    let drop: CGFloat
    let pulse: CGFloat
    
    var body: some View {
        ZStack {
            
            RippleRing(accent: accent, pulse: pulse)
            
            
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 48))
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    LinearGradient(
                        colors: [ILTheme.tertiaryRed, Color.red.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    accent.light.opacity(0.95)
                )
                .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
                .shadow(color: accent.light.opacity(0.4), radius: 12)
                .offset(y: -15 + drop)
        }
        .offset(y: 10)
    }
}

private struct RippleRing: View {
    let accent: ILRewardAccent
    let pulse: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [accent.light.opacity(0.4), accent.mid.opacity(0.1)],
                        startPoint: .center,
                        endPoint: .bottom
                    ),
                    lineWidth: 2
                )
                .frame(width: 50, height: 50)
                .scaleEffect(pulse)
                .opacity(0.6 - Double(pulse) * 0.2)
            
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [accent.light.opacity(0.25), .clear],
                        startPoint: .center,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 70, height: 70)
                .scaleEffect(pulse * 1.3)
                .opacity(0.4)
        }
    }
}


private struct ReadyHero: View {
    let t: TimeInterval
    let accent: ILRewardAccent
    let reduceMotion: Bool
    
    var body: some View {
        ZStack {
            
            OuterSparkles(t: t, accent: accent)

            
            InnerSparkles(t: t)

            
            CentralSeal(accent: accent, t: t, reduceMotion: reduceMotion)
        }
    }
}

private struct OuterSparkles: View {
    let t: TimeInterval
    let accent: ILRewardAccent
    
    var body: some View {
        ForEach(0..<12, id: \.self) { i in
            OuterSparkle(index: i, t: t, accent: accent)
        }
    }
}

private struct OuterSparkle: View {
    let index: Int
    let t: TimeInterval
    let accent: ILRewardAccent
    
    private var angle: Double { Double(index) / 12.0 * Double.pi * 2 + t * 0.3 }
    private var radius: Double { 80 + sin(t * 1.5 + Double(index)) * 12 }
    private var sparkleOpacity: Double { 0.4 + 0.4 * sin(t * 2.5 + Double(index)) }
    private var x: CGFloat { CGFloat(cos(angle)) * CGFloat(radius) }
    private var y: CGFloat { CGFloat(sin(angle)) * CGFloat(radius) }
    private var iconSize: CGFloat { index % 3 == 0 ? 18 : 14 }
    private var rotation: Double { Double(index) * 30 + t * 20 }
    
    var body: some View {
        Image(systemName: index % 2 == 0 ? "sparkle" : "star.fill")
            .font(.system(size: iconSize, weight: .bold))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        ILTheme.semanticSuccess.opacity(sparkleOpacity),
                        accent.light.opacity(sparkleOpacity * 0.8),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: ILTheme.semanticSuccess.opacity(0.5), radius: 6)
            .offset(x: x, y: y)
            .scaleEffect(0.8 + sparkleOpacity * 0.4)
            .rotationEffect(.degrees(rotation))
    }
}

private struct InnerSparkles: View {
    let t: TimeInterval
    
    var body: some View {
        ForEach(0..<6, id: \.self) { i in
            InnerSparkle(index: i, t: t)
        }
    }
}

private struct InnerSparkle: View {
    let index: Int
    let t: TimeInterval
    
    private var angle: Double { Double(index) / 6.0 * Double.pi * 2 - t * 0.5 }
    private var radius: CGFloat { 45 }
    private var pulse: Double { sin(t * 3 + Double(index)) * 0.3 + 0.7 }
    private var x: CGFloat { CGFloat(cos(angle)) * radius }
    private var y: CGFloat { CGFloat(sin(angle)) * radius }
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(ILTheme.iceLight.opacity(pulse))
            .offset(x: x, y: y)
    }
}

private struct CentralSeal: View {
    let accent: ILRewardAccent
    let t: TimeInterval
    let reduceMotion: Bool
    
    private var rotation: Double { reduceMotion ? 0 : sin(t * 1.2) * 8 }
    private var scale: CGFloat { reduceMotion ? 1 : 1 + 0.04 * CGFloat(sin(t * 1.8)) }
    
    var body: some View {
        ZStack {
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ILTheme.semanticSuccess.opacity(0.3),
                            accent.light.opacity(0.15),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)
                .blur(radius: 25)

            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            ILTheme.semanticSuccess,
                            accent.light.opacity(0.95),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: ILTheme.semanticSuccess.opacity(0.55), radius: 20)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .ilBreathingGlow()
        }
    }
}


struct ILOnboardingAmbientDrift: View {
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 18.0, paused: reduceMotion)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            Canvas { cctx, size in
                for i in 0..<20 {
                    let idx = Double(i)
                    let seed = idx * 0.77
                    let x = size.width * (0.1 + CGFloat(sin(seed + t * 0.08 + idx) * 0.4 + 0.4))
                    let y = size.height * (0.05 + CGFloat(cos(seed * 1.1 + t * 0.06) * 0.42 + 0.42))
                    let r: CGFloat = 14 + CGFloat(i % 6) * 6
                    let o: Double = 0.05 + Double(i % 4) * 0.018
                    
                    cctx.fill(
                        Path(ellipseIn: CGRect(x: x - r / 2, y: y - r / 2, width: r, height: r)),
                        with: .color(accent.light.opacity(o))
                    )
                }
            }
            .allowsHitTesting(false)
            .blur(radius: 32)
            .opacity(0.9)
        }
    }
}
