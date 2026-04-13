import SwiftUI

/// Full-screen arctic atmosphere: deep navy base, animated aurora orbs,
/// diagonal ice sheen, edge vignette, subtle film grain. Respects accessibility.
struct ILAtmosphereBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                if reduceTransparency {
                    ILTheme.background
                } else {
                    ILAtmosphereBaseLayer(size: size)

                    if reduceMotion {
                        ILAtmosphereGlowLayer(size: size, breath: 1.0)
                        ILAtmosphereSheen(size: size, t: 0)
                    } else {
                        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { ctx in
                            let t = ctx.date.timeIntervalSinceReferenceDate
                            let breath = 0.91 + 0.09 * CGFloat(sin(t * 0.38))
                            let drift  = CGFloat(sin(t * 0.24)) * 10
                            ZStack {
                                ILAtmosphereGlowLayer(size: size, breath: breath, drift: drift)
                                ILAtmosphereSheen(size: size, t: t)
                            }
                        }
                    }

                    ILAtmosphereVignette(size: size)
                    ILFilmGrainOverlay()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

// MARK: - Base layer

private struct ILAtmosphereBaseLayer: View {
    let size: CGSize
    @Environment(\.ilRewardAccent) private var accent
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "#040A12") ?? ILTheme.background, location: 0),
                    .init(color: Color(hex: "#080E1A") ?? ILTheme.background, location: 0.25),
                    .init(color: Color(hex: "#0A1422") ?? ILTheme.background, location: 0.55),
                    .init(color: Color(hex: "#0C1830") ?? ILTheme.background, location: 0.80),
                    .init(color: Color(hex: "#071020") ?? ILTheme.background, location: 1.0),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            // Subtle cyan hint — top-left
            RadialGradient(
                colors: [accent.light.opacity(0.07), Color.clear],
                center: .init(x: 0.15, y: 0.12),
                startRadius: 10,
                endRadius: min(size.width, size.height) * 0.55
            )
            // Deep blue warmth — bottom right
            RadialGradient(
                colors: [ILTheme.backgroundTertiary.opacity(0.50), Color.clear],
                center: .init(x: 0.88, y: 0.82),
                startRadius: 20,
                endRadius: min(size.width, size.height) * 0.52
            )
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Animated aurora orbs

private struct ILAtmosphereGlowLayer: View {
    let size: CGSize
    var breath: CGFloat
    var drift: CGFloat = 0
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        ZStack {
            // Primary cyan aurora — top right, breathes
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            accent.light.opacity(0.45),
                            accent.mid.opacity(0.22),
                            accent.mid.opacity(0.08),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                )
                .frame(width: 440, height: 440)
                .scaleEffect(breath)
                .offset(x: size.width * 0.22 + drift * 0.25, y: -size.height * 0.14)
                .blur(radius: 70)
                .allowsHitTesting(false)

            // Secondary deep-blue orb — bottom left, counter-breathes
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#0A2848")?.opacity(0.90) ?? ILTheme.backgroundTertiary.opacity(0.90),
                            accent.dark.opacity(0.15),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 170
                    )
                )
                .frame(width: 340, height: 340)
                .scaleEffect(1.85 - breath * 0.06)
                .offset(x: -size.width * 0.26 - drift * 0.18, y: size.height * 0.30)
                .blur(radius: 55)
                .allowsHitTesting(false)

            // Mid cyan accent — centre-bottom
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [accent.mid.opacity(0.18), Color.clear],
                        center: .center, startRadius: 0, endRadius: 120
                    )
                )
                .frame(width: 250, height: 90)
                .offset(x: drift * 0.10, y: size.height * 0.28)
                .blur(radius: 38)
                .allowsHitTesting(false)

            // Faint crown — anchors nav bar zone
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [accent.light.opacity(0.16), Color.clear],
                        center: .center, startRadius: 0, endRadius: 110
                    )
                )
                .frame(width: 220, height: 88)
                .offset(x: drift * 0.08, y: -size.height * 0.12)
                .blur(radius: 32)
                .allowsHitTesting(false)
        }
    }
}

// MARK: - Slow ice sheen

private struct ILAtmosphereSheen: View {
    let size: CGSize
    let t: TimeInterval
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        let shift = CGFloat(sin(t * 0.22)) * 22
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        accent.light.opacity(0.10),
                        accent.mid.opacity(0.05),
                        Color.clear,
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            )
            .frame(width: size.width * 1.6, height: 190)
            .rotationEffect(.degrees(-28))
            .offset(x: size.width * 0.18 + shift, y: -size.height * 0.08)
            .blur(radius: 48)
            .blendMode(.plusLighter)
            .opacity(0.55)
            .allowsHitTesting(false)
    }
}

// MARK: - Vignette

private struct ILAtmosphereVignette: View {
    let size: CGSize
    var body: some View {
        RadialGradient(
            colors: [Color.clear, Color.black.opacity(0.55)],
            center: .center,
            startRadius: 60,
            endRadius: max(size.width, size.height) * 0.86
        )
        .blendMode(.multiply)
        .allowsHitTesting(false)
    }
}

// MARK: - Film grain (hash-based, stable)

private struct ILFilmGrainOverlay: View {
    var body: some View {
        Canvas { ctx, size in
            let step: CGFloat = 14
            var x: CGFloat = 0
            while x < size.width + step {
                var y: CGFloat = 0
                while y < size.height + step {
                    let h = UInt32(bitPattern: Int32(bitPattern: UInt32(x) &* 2654435761 &+ UInt32(y) &* 2246822519))
                    let n = (h ^ (h >> 16)) & 0xFF
                    let o = 0.008 + Double(n) / 255.0 * 0.030
                    ctx.fill(
                        Path(CGRect(x: x, y: y, width: 1.2, height: 1.2)),
                        with: .color(.white.opacity(o))
                    )
                    y += step
                }
                x += step
            }
        }
        .blendMode(.overlay)
        .opacity(0.55)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
