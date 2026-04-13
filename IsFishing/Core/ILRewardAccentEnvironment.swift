import SwiftUI

struct ILRewardAccent: Equatable {
    let light: Color
    let mid: Color
    let dark: Color

    init(theme: ILAppRewardTheme) {
        let t = theme.accentTriplet
        light = t.0
        mid = t.1
        dark = t.2
    }

    static let arcticFallback = ILRewardAccent(theme: .arctic)

    var primaryGradient: LinearGradient {
        LinearGradient(colors: [light, mid], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

private struct ILRewardAccentKey: EnvironmentKey {
    static var defaultValue: ILRewardAccent { ILRewardAccent.arcticFallback }
}

extension EnvironmentValues {
    var ilRewardAccent: ILRewardAccent {
        get { self[ILRewardAccentKey.self] }
        set { self[ILRewardAccentKey.self] = newValue }
    }
}

extension ILGradient {
    static func accentPrimary(_ a: ILRewardAccent) -> LinearGradient {
        a.primaryGradient
    }
}
