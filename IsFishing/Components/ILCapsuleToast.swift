import SwiftUI

struct ILCapsuleToast: View {
    let message: String
    var systemImage: String = "checkmark.circle.fill"
    var tint: Color = ILTheme.semanticSuccess

    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        HStack(spacing: 12) {
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [tint.opacity(0.3), tint.opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 18
                        )
                    )
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(tint.opacity(0.5), lineWidth: 1)
                    )
                
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [tint, .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .ilFloat(range: 1.5, duration: 2)
            }
            
            Text(message)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ILTheme.textPrimaryOnDark, ILTheme.iceLight],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .padding(.leading, 14)
        .padding(.trailing, 20)
        .padding(.vertical, 12)
        .background(
            ZStack {
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                ILTheme.backgroundElevated.opacity(0.92),
                                ILTheme.backgroundSecondary.opacity(0.96),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Capsule()
                    .fill(.ultraThinMaterial.opacity(0.5))
                    .environment(\.colorScheme, .dark)
            }
        )
        .overlay(
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            accent.light.opacity(0.55),
                            ILTheme.divider.opacity(0.8),
                            accent.mid.opacity(0.25),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: .black.opacity(0.45), radius: 16, y: 8)
        .shadow(color: accent.mid.opacity(0.22), radius: 28, y: 12)
        .ilFloat(range: 3, duration: 3.5)
    }
}

struct ILToastModifier: ViewModifier {
    @Binding var message: String?
    @State private var dismissTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if let message {
                ILCapsuleToast(message: message)
                    .padding(.bottom, 100)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .allowsHitTesting(false)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: message)
        .onChange(of: message) { _, new in
            dismissTask?.cancel()
            dismissTask = nil
            guard new != nil else { return }
            let binding = $message
            dismissTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2_600_000_000)
                guard !Task.isCancelled else { return }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    binding.wrappedValue = nil
                }
            }
        }
    }
}

extension View {
    func ilToast(_ message: Binding<String?>) -> some View {
        modifier(ILToastModifier(message: message))
    }
}
