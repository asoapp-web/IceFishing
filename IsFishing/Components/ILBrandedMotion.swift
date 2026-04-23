import SwiftUI



struct ILMapLongPressHint: View {
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0, paused: reduceMotion)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            let pulse: CGFloat = reduceMotion ? 1 : 1 + 0.022 * CGFloat(sin(t * 2.15))
            let iconBob: CGFloat = reduceMotion ? 0 : CGFloat(sin(t * 2.9)) * 2.5
            let glow: CGFloat = reduceMotion ? 0.35 : 0.28 + 0.12 * CGFloat(sin(t * 1.7))

            HStack(spacing: 8) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ILTheme.cyanLight)
                    .offset(y: iconBob)
                    .shadow(color: accent.light.opacity(0.55), radius: glow * 6)
                Text("Long-press to add a spot · Tap a pin for details")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(ILTheme.textSecondaryOnDark)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(
                Capsule()
                    .fill(ILTheme.backgroundElevated.opacity(0.96))
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        accent.light.opacity(0.42 + Double(sin(t * 1.4)) * 0.1),
                                        ILTheme.cyan.opacity(0.35),
                                        ILTheme.iceLight.opacity(0.2),
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: .black.opacity(0.38), radius: 12, y: 4)
            )
            .scaleEffect(pulse)
        }
    }
}



struct ILAvatarAuroraRing: View {
    let diameter: CGFloat
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: reduceMotion)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            let rot = reduceMotion ? 0 : t.truncatingRemainder(dividingBy: 24) / 24 * 360
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [
                            ILTheme.cyanLight.opacity(0.9),
                            accent.light.opacity(0.85),
                            ILTheme.iceLight.opacity(0.65),
                            accent.mid.opacity(0.55),
                            ILTheme.cyanLight.opacity(0.88),
                        ],
                        center: .center
                    ),
                    lineWidth: 2.5
                )
                .frame(width: diameter, height: diameter)
                .rotationEffect(.degrees(rot))
                .blur(radius: reduceMotion ? 0 : 0.35)
                .opacity(reduceMotion ? 0.55 : 0.72 + 0.1 * sin(t * 0.9))
        }
    }
}



struct ILTrophyBarShimmer: View {
    let widthFraction: CGFloat
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { g in
            let w = max(0, g.size.width * widthFraction)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [accent.light, accent.mid, ILTheme.cyanDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: w)
                if w > 24, !reduceMotion {
                    TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { ctx in
                        let t = ctx.date.timeIntervalSinceReferenceDate
                        let travel = CGFloat(sin(t * 2.1)) * (w * 0.35)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0),
                                        Color.white.opacity(0.42),
                                        Color.white.opacity(0),
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: min(48, w * 0.55), height: 8)
                            .offset(x: (w - min(48, w * 0.55)) / 2 + travel)
                            .blendMode(.overlay)
                    }
                }
            }
        }
        .frame(height: 8)
    }
}
