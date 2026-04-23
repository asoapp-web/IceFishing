import Foundation

struct ILSpot: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var date: String
    var notes: String?
    var speciesId: String?
    var photoIds: [String]
    var createdAt: String
    var updatedAt: String
}

struct ILMapStoredRegion: Codable, Equatable {
    var centerLatitude: Double
    var centerLongitude: Double
    var spanLatitudeDelta: Double
    var spanLongitudeDelta: Double
}
