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
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(ILTheme.textPrimaryOnLight)
                Text(message)
                    .font(.body)
                    .foregroundStyle(ILTheme.textSecondaryOnLight)
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text(cancelTitle)
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundStyle(accent.mid)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(accent.mid.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(ILTheme.semanticError))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(RoundedRectangle(cornerRadius: 20).fill(ILTheme.frostWhite))
            .shadow(color: .black.opacity(0.3), radius: 20)
            .transition(.scale.combined(with: .opacity))
        }
        .animation(reduceMotion ? .default : .spring(response: 0.3), value: title)
        .onAppear { ILHaptics.warning() }
    }
}
