import SwiftUI

/// Unlockable accent palettes (Statistics → Themes). Arctic is always available.
enum ILAppRewardTheme: String, CaseIterable, Codable {
    case arctic
    case ember
    case aurora

    var displayName: String {
        switch self {
        case .arctic: return "Arctic Cyan"
        case .ember: return "Ember Dawn"
        case .aurora: return "Aurora Violet"
        }
    }

    var minimumPoints: Int {
        switch self {
        case .arctic: return 0
        case .ember: return 500
        case .aurora: return 2000
        }
    }

    func isUnlocked(trophyPoints: Int) -> Bool {
        trophyPoints >= minimumPoints
    }

    /// Tab bar / highlights: light accent, mid, dark
    var accentTriplet: (Color, Color, Color) {
        switch self {
        case .arctic:
            return (ILTheme.cyanLight, ILTheme.cyan, ILTheme.cyanDark)
        case .ember:
            let a = Color(hex: "#FFB347") ?? ILTheme.amber
            let b = Color(hex: "#FF7A45") ?? ILTheme.amberDark
            let c = Color(hex: "#E85D2C") ?? ILTheme.tertiaryRed
            return (a, b, c)
        case .aurora:
            let a = Color(hex: "#C9A0FF") ?? ILTheme.cyanLight
            let b = Color(hex: "#7B68EE") ?? ILTheme.cyan
            let c = Color(hex: "#4B3F91") ?? ILTheme.cyanDark
            return (a, b, c)
        }
    }
}
