import Foundation

enum ILTrophyTier: String, Codable, CaseIterable {
    case novice
    case angler
    case master
    case legend

    static func tier(forPoints points: Int) -> ILTrophyTier {
        if points >= 5000 { return .legend }
        if points >= 2000 { return .master }
        if points >= 500 { return .angler }
        return .novice
    }

    var displayName: String {
        switch self {
        case .novice: return "Novice"
        case .angler: return "Angler"
        case .master: return "Master"
        case .legend: return "Legend"
        }
    }

    var symbolName: String {
        switch self {
        case .novice: return "leaf.fill"
        case .angler: return "fish.fill"
        case .master: return "star.fill"
        case .legend: return "crown.fill"
        }
    }

    var minimumPoints: Int {
        switch self {
        case .novice: return 0
        case .angler: return 500
        case .master: return 2000
        case .legend: return 5000
        }
    }

    var next: ILTrophyTier? {
        switch self {
        case .novice: return .angler
        case .angler: return .master
        case .master: return .legend
        case .legend: return nil
        }
    }
}
