import Foundation

@MainActor
final class ILBundleContentService {
    static let shared = ILBundleContentService()

    private(set) lazy var guideCategories: [ILGuideCategory] = load("guide_categories")
    private(set) lazy var guideArticles: [ILGuideArticle] = load("guide_articles")
    private(set) lazy var species: [ILSpecies] = load("species")

    private init() {}

    private func load<T: Decodable>(_ name: String) -> T {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            fatalError("Missing bundle resource \(name).json")
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Failed to decode \(name).json: \(error)")
        }
    }

    func category(by id: String) -> ILGuideCategory? {
        guideCategories.first { $0.id == id }
    }

    func article(by id: String) -> ILGuideArticle? {
        guideArticles.first { $0.id == id }
    }

    func species(by id: String) -> ILSpecies? {
        species.first { $0.id == id }
    }

    func articlesLinkingSpecies(id: String) -> [ILGuideArticle] {
        guideArticles.filter { $0.relatedSpeciesIds.contains(id) }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
}
