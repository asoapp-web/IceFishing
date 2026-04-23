import PhotosUI
import SwiftUI

/// Camera + gallery controls styled for dark app chrome. Uses `.plain` / `.borderless` so `Form` rows don’t treat the whole row as one giant button.
struct ILPhotoSourceRow: View {
    @Binding var showCamera: Bool
    @Binding var pickedItems: [PhotosPickerItem]
    let maxGalleryItems: Int
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        let n = max(0, maxGalleryItems)
        HStack(alignment: .center, spacing: 12) {
            Button {
                showCamera = true
            } label: {
                photoChip(icon: "camera.fill", title: "Camera")
            }
            .buttonStyle(.borderless)
            .fixedSize(horizontal: true, vertical: false)

            if n > 0 {
                PhotosPicker(selection: $pickedItems, maxSelectionCount: n, matching: .images) {
                    photoChip(icon: "photo.on.rectangle.angled", title: "Gallery")
                }
                .buttonStyle(.borderless)
                .fixedSize(horizontal: true, vertical: false)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func photoChip(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
            Text(title)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
        }
        .foregroundStyle(accent.light)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(ILTheme.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(accent.light.opacity(0.4), lineWidth: 1)
        )
    }
}

/// Single gallery pick (e.g. notes) + camera, same hit-target fix as `ILPhotoSourceRow`.
struct ILPhotoSinglePickerRow: View {
    @Binding var showCamera: Bool
    @Binding var picked: PhotosPickerItem?
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button {
                showCamera = true
            } label: {
                photoChip(icon: "camera.fill", title: "Camera")
            }
            .buttonStyle(.borderless)
            .fixedSize(horizontal: true, vertical: false)

            PhotosPicker(selection: $picked, matching: .images) {
                photoChip(icon: "photo.on.rectangle.angled", title: "Gallery")
            }
            .buttonStyle(.borderless)
            .fixedSize(horizontal: true, vertical: false)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func photoChip(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
            Text(title)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
        }
        .foregroundStyle(accent.light)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(ILTheme.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(accent.light.opacity(0.4), lineWidth: 1)
        )
    }
}
