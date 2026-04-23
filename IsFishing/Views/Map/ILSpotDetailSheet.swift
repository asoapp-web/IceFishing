import SwiftUI

struct ILSpotDetailSheet: View {
    let spot: ILSpot
    let onEdit: () -> Void
    let onDismiss: () -> Void
    @Environment(\.ilRewardAccent) private var accent

    private let content = ILBundleContentService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                ILAtmosphereBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        photoSection
                        Text(spot.name)
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                        metaRow
                        if let notes = spot.notes, !notes.isEmpty {
                            detailBlock(title: "Notes", text: notes)
                        } else {
                            Text("No notes for this spot yet.")
                                .font(.subheadline)
                                .foregroundStyle(ILTheme.textMutedOnDark)
                        }
                        coordinatesBlock
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(ILTheme.textSecondaryOnDark)
                    }
                    .accessibilityLabel("Close")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        onEdit()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(accent.light)
                }
            }
        }
    }

    @ViewBuilder
    private var photoSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(ILTheme.backgroundTertiary)
            if let first = spot.photoIds.first,
               let ui = ILImageStorageService.loadImage(id: first, subfolder: "spots") {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(accent.light.opacity(0.45))
                    Text("Add photos when you edit this spot")
                        .font(.caption)
                        .foregroundStyle(ILTheme.textMutedOnDark)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [accent.light.opacity(0.35), ILTheme.divider],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.35), radius: 12, y: 5)
    }

    private var metaRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(accent.light.opacity(0.75))
                Text(ILDateFormatting.displayDate(fromISO: spot.date))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(ILTheme.textSecondaryOnDark)
            }
            if let sid = spot.speciesId, let sp = content.species(by: sid) {
                HStack(spacing: 8) {
                    Image(systemName: "fish.fill")
                        .font(.caption)
                        .foregroundStyle(accent.light.opacity(0.75))
                    Text(sp.commonName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                }
            }
            if spot.photoIds.count > 1 {
                Text("\(spot.photoIds.count) photos")
                    .font(.caption)
                    .foregroundStyle(ILTheme.textMutedOnDark)
            }
        }
    }

    private func detailBlock(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(ILTheme.textPrimaryOnDark)
            Text(text)
                .font(.body)
                .foregroundStyle(ILTheme.textSecondaryOnDark)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(ILTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ILTheme.divider, lineWidth: 1)
        )
    }

    private var coordinatesBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Coordinates")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ILTheme.textMutedOnDark)
            Text(String(format: "%.5f°, %.5f°", spot.latitude, spot.longitude))
                .font(.caption.monospacedDigit())
                .foregroundStyle(ILTheme.textSecondaryOnDark)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(ILTheme.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
