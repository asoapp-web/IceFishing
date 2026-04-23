import SwiftUI

struct ILConfirmationDialog: View {
    let title: String
    let message: String
    let confirmTitle: String
    var cancelTitle: String = "Cancel"
    var isDestructive: Bool = true
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        ZStack {
            
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .background(.ultraThinMaterial.opacity(0.3))
                .environment(\.colorScheme, .dark)
                .onTapGesture { onCancel() }

            VStack(alignment: .leading, spacing: 18) {
                
                Text(title)
                    .font(.ilPolarSerif(24, weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ILTheme.frostWhite, ILTheme.iceLight, accent.light.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: accent.light.opacity(0.3), radius: 12, x: 0, y: 0)
                
                Text(message)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(ILTheme.textSecondaryOnDark)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text(cancelTitle)
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(ILTheme.backgroundTertiary)
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.ultraThinMaterial.opacity(0.3))
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [accent.light.opacity(0.4), ILTheme.divider.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                Group {
                                    if isDestructive {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: [ILTheme.semanticError, ILTheme.tertiaryRed],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    } else {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: [accent.light, accent.mid, accent.dark],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.8)
                            )
                            .shadow(
                                color: (isDestructive ? ILTheme.semanticError : accent.light).opacity(0.5),
                                radius: 16, x: 0, y: 6
                            )
                            .ilPulsingGlow()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
            .frame(maxWidth: 340)
            .background(
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    ILTheme.backgroundElevated.opacity(0.96),
                                    ILTheme.backgroundSecondary.opacity(0.94),
                                    ILTheme.background.opacity(0.98),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial.opacity(0.4))
                        .environment(\.colorScheme, .dark)
                    
                    
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.clear,
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                        .padding(0.5)
                }
            )
            .overlay(
                
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                accent.light.opacity(0.5),
                                accent.mid.opacity(0.2),
                                ILTheme.divider.opacity(0.8),
                                accent.light.opacity(0.15),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: .black.opacity(0.55), radius: 32, y: 16)
            .shadow(color: accent.mid.opacity(0.2), radius: 48, y: 20)
            .transition(.scale(scale: 0.85).combined(with: .opacity))
            .ilFloat(range: 4, duration: 4)
        }
        .animation(reduceMotion ? .default : .spring(response: 0.35, dampingFraction: 0.75), value: title)
        .onAppear { ILHaptics.warning() }
    }
}
