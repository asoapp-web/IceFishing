import SwiftUI

struct ILEmptyState: View {
    let icon: String
    let message: String
    // Legacy param kept for source compat but ignored — always dark
    var onDark: Bool = true

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(ILTheme.backgroundTertiary)
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(ILTheme.textMutedOnDark)
            }
            Text(message)
                .font(.system(.subheadline, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(ILTheme.textMutedOnDark)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
