import Foundation

struct ILCatchEntry: Codable, Identifiable, Equatable {
    var id: String
    var speciesId: String?
    var customSpeciesName: String?
    var quantity: Int
    var sizeEstimate: String?
    var note: String?
}

struct ILSession: Codable, Identifiable, Equatable {
    var id: String
    var date: String
    var durationMinutes: Int?
    var comment: String?
    var spotId: String?
    var catchEntries: [ILCatchEntry]
    var photoIds: [String]
    var createdAt: String
    var updatedAt: String
}
