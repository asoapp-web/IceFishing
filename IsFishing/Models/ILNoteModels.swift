import Foundation

struct ILNote: Codable, Identifiable, Equatable {
    var id: String
    var text: String
    var photoId: String?
    var createdAt: String
    var updatedAt: String
}
