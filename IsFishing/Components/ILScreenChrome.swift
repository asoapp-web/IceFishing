import SwiftUI

/// Distinctive screen title block: kicker · gradient title · optional accessory · frost rule.
struct ILScreenHeroHeader<Accessory: View>: View {
    let kicker: String
    let title: String
    var systemIcon: String?
    @ViewBuilder var accessory: () -> Accessory

    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(kicker: String, title: String, systemIcon: String? = nil, @ViewBuilder accessory: @escaping () -> Accessory) {
        self.kicker = kicker
        self.title = title
        self.systemIcon = systemIcon
        self.accessory = accessory
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 16) {
                if let systemIcon {
                    ZStack {
                        
                        Circle()
                            .fill(accent.light.opacity(0.15))
                            .frame(width: 56, height: 56)
                            .blur(radius: 12)
                        
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        accent.light.opacity(0.28),
                                        ILTheme.backgroundTertiary.opacity(0.98),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                accent.light.opacity(0.65),
                                                ILTheme.divider.opacity(0.4),
                                                accent.light.opacity(0.25),
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.2
                                    )
                            )
                            .shadow(color: accent.mid.opacity(0.35), radius: 16, y: 6)
                        
                        Image(systemName: systemIcon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ILTheme.frostWhite, accent.light, accent.mid],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: accent.light.opacity(0.5), radius: 8, x: 0, y: 0)
                    }
                    .modifier(ILIconIdleSway(reduceMotion: reduceMotion))
                    .ilBreathingGlow()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(kicker.uppercased())
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .tracking(2.8)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [accent.light.opacity(0.95), ILTheme.cyanLight.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: accent.light.opacity(0.3), radius: 6, x: 0, y: 0)

                    Text(title)
                        .font(.ilPolarSerif(36, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    ILTheme.frostWhite,
                                    ILTheme.iceLight,
                                    accent.light.opacity(0.95),
                                ],
                                startPoint: .leading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.55), radius: 0, y: 2)
                        .shadow(color: accent.mid.opacity(0.35), radius: 20, y: 5)

                    accessory()
                }
            }

            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(ILTheme.divider.opacity(0.5))
                    .frame(height: 3)
                
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                accent.light,
                                ILTheme.cyanLight,
                                accent.light.opacity(0.6),
                                Color.clear,
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 3)
                    .ilShimmer()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 3)
        }
    }
}

private struct ILIconIdleSway: ViewModifier {
    let reduceMotion: Bool
    @State private var sway: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(Double(sway)))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                    sway = 2.2
                }
            }
    }
}
