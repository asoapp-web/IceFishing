import SwiftUI

enum ILSpeciesSort: String, CaseIterable {
    case az     = "A → Z"
    case za     = "Z → A"
    case winter = "Winter first"
}

struct ILSpeciesScreen: View {
    @Binding var toast: String?
    @EnvironmentObject private var router: ILAppRouter
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent
    @State private var search = ""
    @State private var selectedTags: Set<String> = []
    @State private var sort: ILSpeciesSort = .az
    @FocusState private var searchFocused: Bool

    private let content = ILBundleContentService.shared

    private let allFilterTags: [String] = [
        "Lake", "River", "Reservoir", "Pond", "Brackish",
        "North America", "Northern Europe", "Siberia / Northern Asia",
        "Prime Winter Target", "Winter Active", "Less Active in Winter",
        "Predator", "Panfish", "Bottom Feeder",
    ]

    private var filtered: [ILSpecies] {
        var list = content.species
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            list = list.filter {
                $0.commonName.lowercased().contains(q) || $0.latinName.lowercased().contains(q)
            }
        }
        if !selectedTags.isEmpty {
            list = list.filter { sp in
                let flat = Set(sp.tags.waterType + sp.tags.region + [sp.tags.winterRelevance] + sp.tags.feeding)
                return selectedTags.allSatisfy { flat.contains($0) }
            }
        }
        switch sort {
        case .az:     list.sort { $0.commonName < $1.commonName }
        case .za:     list.sort { $0.commonName > $1.commonName }
        case .winter: list.sort { winterRank($0) < winterRank($1) }
        }
        return list
    }

    private func winterRank(_ s: ILSpecies) -> Int {
        switch s.tags.winterRelevance {
        case "Prime Winter Target": return 0
        case "Winter Active":       return 1
        default:                    return 2
        }
    }

    var body: some View {
        ZStack {
            ILAtmosphereBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Species")
                            .font(.ilDisplay(32))
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                        HStack(spacing: 6) {
                            let total = content.species.count
                            let exp   = store.exploredSpeciesIds.count
                            Image(systemName: "binoculars.fill")
                                .font(.caption)
                                .foregroundStyle(accent.light.opacity(0.6))
                            Text("\(exp) of \(total) species explored")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(ILTheme.textMutedOnDark)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                    // Search + sort row
                    HStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(searchFocused ? accent.light : ILTheme.textMutedOnDark)
                            TextField("", text: $search, prompt: Text("Search species…").foregroundStyle(ILTheme.iceLight.opacity(0.72)))
                                .textFieldStyle(.plain)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(ILTheme.textPrimaryOnDark)
                                .tint(accent.light)
                                .focused($searchFocused)
                            if !search.isEmpty {
                                Button { search = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 13))
                                        .foregroundStyle(ILTheme.textMutedOnDark)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(ILTheme.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(searchFocused ? accent.light.opacity(0.5) : ILTheme.divider, lineWidth: 1)
                        )

                        Menu {
                            Picker("Sort", selection: $sort) {
                                ForEach(ILSpeciesSort.allCases, id: \.self) { s in
                                    Text(s.rawValue).tag(s)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(accent.light)
                                .frame(width: 44, height: 44)
                                .background(ILTheme.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(ILTheme.divider, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                    // Tag filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(allFilterTags, id: \.self) { tag in
                                let on = selectedTags.contains(tag)
                                Button {
                                    withAnimation(.easeInOut(duration: 0.18)) {
                                        if on { selectedTags.remove(tag) } else { selectedTags.insert(tag) }
                                    }
                                    ILHaptics.light()
                                } label: {
                                    Text(tag)
                                        .font(.system(size: 12, weight: on ? .semibold : .medium, design: .rounded))
                                        .foregroundStyle(on ? accent.light : ILTheme.textSecondaryOnDark)
                                        .padding(.horizontal, 11)
                                        .padding(.vertical, 7)
                                        .background(Capsule().fill(on ? accent.light.opacity(0.15) : ILTheme.backgroundTertiary))
                                        .overlay(Capsule().stroke(on ? accent.light.opacity(0.45) : ILTheme.divider, lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                            if !selectedTags.isEmpty {
                                Button {
                                    withAnimation { selectedTags.removeAll() }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                        Text("Clear")
                                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    }
                                    .foregroundStyle(ILTheme.tertiaryRed)
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 7)
                                    .background(Capsule().fill(ILTheme.tertiaryRed.opacity(0.12)))
                                    .overlay(Capsule().stroke(ILTheme.tertiaryRed.opacity(0.35), lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 16)

                    // Results
                    if filtered.isEmpty {
                        ILEmptyState(icon: "fish.fill", message: "No species match your filters.")
                            .frame(minHeight: 280)
                            .padding(.horizontal, 20)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(filtered) { sp in
                                speciesCard(sp)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.bottom, 120)
            }
        }
    }

    private func speciesCard(_ sp: ILSpecies) -> some View {
        let isExplored = store.exploredSpeciesIds.contains(sp.id)
        return Button { router.openSpeciesDetail(id: sp.id) } label: {
            HStack(alignment: .center, spacing: 14) {
                speciesThumb(sp)
                VStack(alignment: .leading, spacing: 5) {
                    Text(sp.commonName)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                    Text(sp.latinName)
                        .font(.caption)
                        .italic()
                        .foregroundStyle(accent.light.opacity(0.75))
                    HStack(spacing: 6) {
                        ForEach(Array(sp.tags.waterType.prefix(2)), id: \.self) { t in
                            Text(t)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(accent.light)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(accent.light.opacity(0.13)))
                                .overlay(Capsule().stroke(accent.light.opacity(0.25), lineWidth: 0.5))
                        }
                        if sp.tags.winterRelevance == "Prime Winter Target" {
                            Text("❄️ Prime")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(ILTheme.amber)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(ILTheme.amber.opacity(0.13)))
                        }
                    }
                }
                Spacer()
                VStack(spacing: 4) {
                    if isExplored {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(ILTheme.semanticSuccess)
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
                            colors: [accent.light.opacity(0.18), ILTheme.divider],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }

    private func speciesThumb(_ sp: ILSpecies) -> some View {
        ILSpeciesImageView(imageName: sp.thumbnailName)
            .frame(width: 68, height: 68)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(ILTheme.divider, lineWidth: 1)
            )
    }
}
