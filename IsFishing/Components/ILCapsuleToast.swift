import SwiftUI

struct ILCapsuleToast: View {
    let message: String
    var systemImage: String = "checkmark.circle.fill"
    var tint: Color = ILTheme.semanticSuccess

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
            Text(message)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(ILTheme.textPrimaryOnDark)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Capsule().fill(ILTheme.slate.opacity(0.95)))
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
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
