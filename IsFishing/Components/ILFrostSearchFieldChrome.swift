import SwiftUI

/// Shared chrome for Guide / Map search rows — matches frost gradient, border, and shadow.
struct ILFrostSearchFieldChrome: ViewModifier {
    var focused: Bool

    @Environment(\.ilRewardAccent) private var accent

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ILTheme.backgroundSecondary,
                                ILTheme.backgroundTertiary.opacity(0.92),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                focused ? accent.light.opacity(0.55) : Color.white.opacity(0.06),
                                ILTheme.divider,
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: focused ? 1.5 : 1
                    )
            )
            .shadow(color: .black.opacity(focused ? 0.35 : 0.2), radius: focused ? 12 : 6, y: 4)
    }
}

extension View {
    func ilFrostSearchFieldChrome(focused: Bool) -> some View {
        modifier(ILFrostSearchFieldChrome(focused: focused))
    }
}
