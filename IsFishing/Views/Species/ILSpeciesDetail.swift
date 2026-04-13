import SwiftUI

struct ILSpeciesDetailEmbedded: View {
    let species: ILSpecies
    var onOpenArticle: ((String) -> Void)?
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.ilRewardAccent) private var accent
    @State private var expanded: Set<String> = ["desc", "bait"]

    private let content = ILBundleContentService.shared

    var body: some View {
        ZStack {
            ILAtmosphereBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(species.commonName)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(species.latinName)
                        .font(.system(.title3, design: .default))
                        .italic()
                        .foregroundStyle(accent.light)
                        .fixedSize(horizontal: false, vertical: true)
                    hero
                    tagScroll
                    sectionCard(id: "desc", title: "Description", text: species.description)
                    sectionCard(id: "habitat", title: "Habitat", text: species.habitat)
                    sectionCard(id: "season", title: "Seasonality", text: species.seasonality)
                    sectionCard(id: "behavior", title: "Behavior", text: species.behavior)
                    sectionCard(id: "bait", title: "Bait & Tackle", text: species.baitAndTackle)
                    funFacts
                    relatedArticles
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(accent.light)
        .onAppear {
            store.markSpeciesExplored(species.id)
        }
    }

    private var hero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(ILTheme.backgroundTertiary)
            ILSpeciesImageView(imageName: species.imageName, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
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

    private var tagScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(allTags, id: \.self) { t in
                    Text(t)
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(accent.light.opacity(0.14)))
                        .foregroundStyle(accent.light)
                        .overlay(Capsule().stroke(accent.light.opacity(0.28), lineWidth: 0.5))
                }
            }
        }
    }

    private var allTags: [String] {
        species.tags.waterType + species.tags.region + [species.tags.winterRelevance] + species.tags.feeding
    }

    private func sectionCard(id: String, title: String, text: String) -> some View {
        DisclosureGroup(isExpanded: Binding(
            get: { expanded.contains(id) },
            set: { new in
                if new { expanded.insert(id) } else { expanded.remove(id) }
            }
        )) {
            Text(text)
                .font(.system(.body, design: .default))
                .foregroundStyle(ILTheme.textSecondaryOnDark)
        } label: {
            Text(title)
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(ILTheme.textPrimaryOnDark)
        }
        .padding(14)
        .background(ILTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ILTheme.divider, lineWidth: 1)
        )
    }

    private var funFacts: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(species.funFacts, id: \.self) { f in
                    Text("• \(f)")
                        .font(.system(.body, design: .default))
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                }
            }
        } label: {
            Text("Fun Facts")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(ILTheme.textPrimaryOnDark)
        }
        .padding(14)
        .background(ILTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ILTheme.divider, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var relatedArticles: some View {
        let arts = content.articlesLinkingSpecies(id: species.id)
        if !arts.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Related Articles")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(ILTheme.textPrimaryOnDark)
                ForEach(arts) { a in
                    Button {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            onOpenArticle?(a.id)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundStyle(accent.light)
                            Text(a.title)
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(ILTheme.textPrimaryOnDark)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(ILTheme.textMutedOnDark)
                        }
                        .padding(12)
                        .background(ILTheme.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(ILTheme.divider, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ILSpeciesDetailSheet: View {
    let species: ILSpecies
    let onClose: () -> Void
    var onOpenArticle: ((String) -> Void)?

    var body: some View {
        NavigationStack {
            ILSpeciesDetailEmbedded(species: species, onOpenArticle: onOpenArticle)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            onClose()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(ILTheme.textSecondaryOnDark)
                        }
                        .accessibilityLabel("Close")
                    }
                }
        }
    }
}
