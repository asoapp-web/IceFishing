import SwiftUI

struct ILEmptyState: View {
    let icon: String
    let message: String
    /// Legacy param — always dark in current design.
    var onDark: Bool = true
    var animated: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 15.0, paused: reduceMotion || !animated)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            let bob = (reduceMotion || !animated) ? 0 : sin(t * 1.4) * 3
            let glow = (reduceMotion || !animated) ? 1.0 : 0.92 + 0.08 * sin(t * 1.1)
            let ringPulse = (reduceMotion || !animated) ? 1.0 : 1.0 + 0.04 * sin(t * 0.9)

            VStack(spacing: 18) {
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .strokeBorder(
                                accent.light.opacity(0.12 - Double(i) * 0.03),
                                lineWidth: 1.2
                            )
                            .frame(width: 88 + CGFloat(i) * 28, height: 88 + CGFloat(i) * 28)
                            .scaleEffect(ringPulse)
                    }
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    accent.light.opacity(0.15),
                                    ILTheme.backgroundTertiary,
                                ],
                                center: .center,
                                startRadius: 2,
                                endRadius: 48
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(glow)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [accent.light.opacity(0.45), ILTheme.divider],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        )
                    Image(systemName: icon)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ILTheme.iceLight, accent.light.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .offset(y: bob)
                        .shadow(color: accent.mid.opacity(0.35), radius: 8)
                }
                Text(message)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(ILTheme.textSecondaryOnDark)
                    .padding(.horizontal, 28)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
