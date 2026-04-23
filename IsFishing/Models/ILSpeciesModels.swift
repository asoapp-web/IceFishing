import Foundation

struct ILSpeciesTags: Codable, Hashable {
    var waterType: [String]
    var region: [String]
    var winterRelevance: String
    var feeding: [String]
}

struct ILSpecies: Codable, Identifiable, Hashable {
    let id: String
    let commonName: String
    let latinName: String
    let imageName: String
    let thumbnailName: String
    var tags: ILSpeciesTags
    let description: String
    let habitat: String
    let seasonality: String
    let behavior: String
    let baitAndTackle: String
    let funFacts: [String]
    let relatedArticleIds: [String]
    let sortOrder: Int
}
