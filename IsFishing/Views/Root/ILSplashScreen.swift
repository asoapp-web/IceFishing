import SwiftUI

struct ILSplashScreen: View {
    let onFinished: () -> Void
    @State private var progress: CGFloat = 0
    @State private var textOpacity: Double = 0
    @State private var ringPulse: CGFloat = 1.0
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let loadDuration: Double = 3.0
    private let finishHold: Double = 0.35

    var body: some View {
        ZStack {
            ILAtmosphereBackground()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                // Ice hole + fish (fish rise = progress)
                ZStack {
                    Circle()
                        .fill(accent.light.opacity(0.08))
                        .frame(width: 168, height: 168)
                        .scaleEffect(ringPulse)
                        .blur(radius: 18)

                    // Outer ice ring (animated trim = progress along “reel” metaphor)
                    Circle()
                        .strokeBorder(
                            AngularGradient(
                                colors: [
                                    accent.light,
                                    accent.mid,
                                    ILTheme.backgroundElevated,
                                    accent.light,
                                ],
                                center: .center
                            ),
                            lineWidth: 5
                        )
                        .frame(width: 128, height: 128)
                        .rotationEffect(.degrees(reduceMotion ? 0 : Double(progress) * 360))

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "#B8D8EC")?.opacity(0.88) ?? ILTheme.iceLight.opacity(0.88),
                                    Color(hex: "#7EB8D4")?.opacity(0.72) ?? ILTheme.iceLight.opacity(0.72),
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 64
                            )
                        )
                        .frame(width: 118, height: 118)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [accent.dark.opacity(0.88), ILTheme.background],
                                center: .center, startRadius: 6, endRadius: 48
                            )
                        )
                        .frame(width: 92, height: 92)
                        .overlay(
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(accent.light, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .frame(width: 88, height: 88)
                        )

                    Image(systemName: "fish.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [accent.light, accent.dark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: accent.mid.opacity(0.55), radius: 6)
                        .offset(y: 34 - progress * 52)
                        .opacity(0.35 + Double(progress) * 0.65)
                }
                .padding(.bottom, 20)

                VStack(spacing: 10) {
                    Text("Is Fishing")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                    Text("Ice Fishing Companion")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(accent.light.opacity(0.85))
                }
                .opacity(textOpacity)
                    .multilineTextAlignment(.center)

                Spacer()
                    .frame(height: 24)

                // Progress bar (“reeling in”)
                VStack(spacing: 8) {
                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(ILTheme.backgroundTertiary)
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [accent.dark, accent.light],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(8, g.size.width * progress))
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 48)

                    Text(progress >= 1 ? "Ready" : "Loading…")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(ILTheme.textMutedOnDark)
                }
                .padding(.bottom, 40)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .statusBarHidden(true)
        .onAppear {
            textOpacity = 1
            if reduceMotion {
                progress = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + loadDuration + finishHold) { onFinished() }
            } else {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    ringPulse = 1.08
                }
                withAnimation(.linear(duration: loadDuration)) {
                    progress = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + loadDuration + finishHold) {
                    onFinished()
                }
            }
        }
    }
}
