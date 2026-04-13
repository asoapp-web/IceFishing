import SwiftUI

struct ILArticleReader: View {
    let article: ILGuideArticle
    let onClose: () -> Void
    var onOpenRelatedArticle: ((String) -> Void)?
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private let content = ILBundleContentService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(article.title)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(ILTheme.textPrimaryOnLight)
                    ForEach(Array(article.sections.enumerated()), id: \.offset) { _, section in
                        if let h = section.heading {
                            Text(h)
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .foregroundStyle(ILTheme.textPrimaryOnLight)
                        }
                        Text(section.body)
                            .font(.system(.body, design: .default))
                            .foregroundStyle(ILTheme.textPrimaryOnLight)
                            .lineSpacing(4)
                        if let name = section.imageName, let ui = UIImage(named: name) {
                            VStack(alignment: .leading, spacing: 6) {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                if let cap = section.imageCaption {
                                    Text(cap)
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundStyle(ILTheme.textSecondaryOnLight)
                                }
                            }
                        }
                    }
                    if !article.relatedSpeciesIds.isEmpty {
                        Text("Related species")
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundStyle(ILTheme.textPrimaryOnLight)
                        ForEach(article.relatedSpeciesIds, id: \.self) { sid in
                            if let sp = content.species(by: sid) {
                                NavigationLink(value: sp) {
                                    HStack {
                                        speciesThumb(sp)
                                        VStack(alignment: .leading) {
                                            Text(sp.commonName)
                                                .font(.system(.headline, design: .rounded, weight: .semibold))
                                            Text(sp.latinName)
                                                .font(.system(.caption, design: .default))
                                                .italic()
                                                .foregroundStyle(accent.mid)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(ILTheme.textSecondaryOnLight)
                                    }
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 14).fill(ILTheme.iceLight))
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .background(ILGradient.vertical(ILTheme.iceLight, ILTheme.frostWhite))
            .navigationDestination(for: ILSpecies.self) { sp in
                ILSpeciesDetailEmbedded(species: sp, onOpenArticle: { id in
                    onOpenRelatedArticle?(id)
                })
                    .environmentObject(store)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(ILTheme.textPrimaryOnLight)
                    }
                    .accessibilityLabel("Close")
                }
                ToolbarItem(placement: .principal) {
                    Text(content.category(by: article.categoryId)?.name ?? "")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(ILTheme.textSecondaryOnLight)
                }
            }
            .toolbarBackground(reduceTransparency ? .visible : .automatic, for: .navigationBar)
        }
        .onDisappear {
            store.markArticleRead(article.id)
        }
    }

    private func speciesThumb(_ sp: ILSpecies) -> some View {
        Group {
            if let ui = UIImage(named: sp.thumbnailName) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "fish.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .foregroundStyle(accent.mid)
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(RoundedRectangle(cornerRadius: 10).fill(ILTheme.slate.opacity(0.15)))
    }
}
