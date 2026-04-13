import SwiftUI

struct ILGuideScreen: View {
    @Binding var toast: String?
    @EnvironmentObject private var router: ILAppRouter
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent
    @State private var search = ""
    @State private var selectedCategoryId: String? = nil
    @FocusState private var searchFocused: Bool

    private let content = ILBundleContentService.shared

    private var filteredArticles: [ILGuideArticle] {
        var list = content.guideArticles.sorted { $0.sortOrder < $1.sortOrder }
        if let cid = selectedCategoryId {
            list = list.filter { $0.categoryId == cid }
        }
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            list = list.filter {
                $0.title.lowercased().contains(q) || $0.subtitle.lowercased().contains(q)
                    || $0.sections.contains { $0.body.lowercased().contains(q) }
            }
        }
        return list
    }

    var body: some View {
        ZStack {
            ILAtmosphereBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Guide")
                            .font(.ilDisplay(32))
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                        HStack(spacing: 6) {
                            let total = content.guideArticles.count
                            let read  = store.readArticleIds.count
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(read == total ? ILTheme.semanticSuccess : ILTheme.textMutedOnDark)
                                .font(.caption)
                            Text("\(read) of \(total) articles read")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(ILTheme.textMutedOnDark)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                    // Category chips
                    chipRow
                        .padding(.bottom, 14)

                    // Search
                    searchField
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    // Articles
                    if filteredArticles.isEmpty {
                        ILEmptyState(icon: "magnifyingglass", message: "No articles found.")
                            .frame(minHeight: 280)
                            .padding(.horizontal, 20)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredArticles) { article in
                                articleCard(article)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.bottom, 120)
            }
        }
    }

    // MARK: - Chips

    private var chipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", icon: nil, selected: selectedCategoryId == nil) {
                    selectedCategoryId = nil
                }
                ForEach(content.guideCategories.sorted { $0.sortOrder < $1.sortOrder }) { cat in
                    chip(title: cat.name, icon: cat.iconSymbol, selected: selectedCategoryId == cat.id) {
                        selectedCategoryId = selectedCategoryId == cat.id ? nil : cat.id
                        ILHaptics.light()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func chip(title: String, icon: String?, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(selected ? accent.light : ILTheme.textSecondaryOnDark)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(selected ? accent.light.opacity(0.15) : ILTheme.backgroundTertiary)
            )
            .overlay(Capsule().stroke(selected ? accent.light.opacity(0.45) : ILTheme.divider, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Search

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(searchFocused ? accent.light : ILTheme.textMutedOnDark)
            TextField("", text: $search, prompt: Text("Search articles…").foregroundStyle(ILTheme.iceLight.opacity(0.72)))
                .textFieldStyle(.plain)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(ILTheme.textPrimaryOnDark)
                .tint(accent.light)
                .focused($searchFocused)
            if !search.isEmpty {
                Button {
                    search = ""
                    searchFocused = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(ILTheme.textMutedOnDark)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(ILTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(searchFocused ? accent.light.opacity(0.5) : ILTheme.divider, lineWidth: 1)
        )
    }

    // MARK: - Article card

    private func articleCard(_ article: ILGuideArticle) -> some View {
        let isRead = store.readArticleIds.contains(article.id)
        return Button {
            router.openGuideArticle(id: article.id)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(accent.light.opacity(0.13))
                        .frame(width: 50, height: 50)
                    Image(systemName: article.iconSymbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(accent.light)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(article.title)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                        .lineLimit(2)
                    Text(article.subtitle)
                        .font(.caption)
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                        .lineLimit(2)
                    if let cat = content.category(by: article.categoryId) {
                        Text(cat.name.uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.8)
                            .foregroundStyle(accent.light.opacity(0.7))
                    }
                }

                Spacer(minLength: 4)

                VStack(spacing: 4) {
                    if isRead {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(ILTheme.semanticSuccess)
                    }
                    if !article.relatedSpeciesIds.isEmpty {
                        Image(systemName: "fish.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(accent.light.opacity(0.5))
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(ILTheme.textMutedOnDark)
                }
            }
            .padding(14)
            .background(ILTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                isRead ? ILTheme.semanticSuccess.opacity(0.30) : accent.light.opacity(0.18),
                                ILTheme.divider,
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }
}
