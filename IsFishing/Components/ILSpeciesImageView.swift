import SwiftUI

/// Hero / list image from bundled asset catalog (`imageName`).
struct ILSpeciesImageView: View {
    let imageName: String
    var contentMode: ContentMode = .fill
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        Group {
            if let ui = UIImage(named: imageName) {
                Image(uiImage: ui)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                ZStack {
                    ILTheme.backgroundTertiary
                    Image(systemName: "fish.fill")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(accent.light.opacity(0.6))
                }
            }
        }
    }
}
