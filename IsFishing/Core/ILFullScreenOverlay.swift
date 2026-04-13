import Foundation

/// Presented from `ILMainShellView` so the custom tab bar stays behind a true full-screen cover.
enum ILFullScreenOverlay: Identifiable, Equatable {
    case guideArticle(String)
    case species(String)

    var id: String {
        switch self {
        case .guideArticle(let s): return "g:\(s)"
        case .species(let s): return "s:\(s)"
        }
    }
}
