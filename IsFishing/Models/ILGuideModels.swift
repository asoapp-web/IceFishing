import Foundation

struct ILGuideCategory: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let iconSymbol: String
    let sortOrder: Int
}

struct ILArticleSection: Codable, Hashable {
    var heading: String?
    var body: String
    var imageName: String?
    var imageCaption: String?
}

struct ILGuideArticle: Codable, Identifiable, Hashable {
    let id: String
    let categoryId: String
    let title: String
    let subtitle: String
    let iconSymbol: String
    var sections: [ILArticleSection]
    let relatedSpeciesIds: [String]
    let sortOrder: Int
}
