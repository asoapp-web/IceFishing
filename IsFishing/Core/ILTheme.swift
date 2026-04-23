import SwiftUI



enum ILTheme {
    
    static let background     = Color(hex: "#080E1A") ?? Color(red: 0.031, green: 0.055, blue: 0.102)
    static let backgroundSecondary = Color(hex: "#0D1825") ?? Color(red: 0.051, green: 0.094, blue: 0.145)
    static let backgroundTertiary  = Color(hex: "#122030") ?? Color(red: 0.071, green: 0.125, blue: 0.188)
    static let backgroundElevated  = Color(hex: "#182840") ?? Color(red: 0.094, green: 0.157, blue: 0.251)

    
    static let deepNight  = background
    static let slate      = backgroundSecondary
    static let iceLight   = Color(hex: "#C8DCF0") ?? Color(red: 0.784, green: 0.863, blue: 0.941)
    static let frostWhite = Color(hex: "#EBF2FA") ?? Color(red: 0.922, green: 0.949, blue: 0.980)

    
    static let cyan      = Color(hex: "#00C8E0") ?? Color(red: 0.0,   green: 0.784, blue: 0.878)
    static let cyanLight = Color(hex: "#38E0F5") ?? Color(red: 0.220, green: 0.878, blue: 0.961)
    static let cyanDark  = Color(hex: "#0098B0") ?? Color(red: 0.0,   green: 0.596, blue: 0.690)

    
    static let amber     = Color(hex: "#F5A623") ?? Color(red: 0.961, green: 0.651, blue: 0.137)
    static let amberDark = Color(hex: "#C47B00") ?? Color(red: 0.769, green: 0.482, blue: 0.0)

    
    static let tertiaryRed    = Color(hex: "#E03545") ?? Color(red: 0.878, green: 0.208, blue: 0.271)
    static let semanticError   = Color(hex: "#D41C2E") ?? Color(red: 0.831, green: 0.110, blue: 0.180)
    static let semanticSuccess = Color(hex: "#1AAB56") ?? Color(red: 0.102, green: 0.671, blue: 0.337)

    
    static let textPrimaryOnDark   = Color(hex: "#E8F2FF") ?? Color.white
    static let textSecondaryOnDark = Color(hex: "#7BA4C8") ?? Color(red: 0.482, green: 0.643, blue: 0.784)
    static let textMutedOnDark     = Color(hex: "#3D5C7A") ?? Color(red: 0.239, green: 0.361, blue: 0.478)

    
    static let textPrimaryOnLight   = Color(hex: "#0C1A2E") ?? Color(red: 0.047, green: 0.102, blue: 0.180)
    static let textSecondaryOnLight = Color(hex: "#3A5577") ?? Color(red: 0.227, green: 0.333, blue: 0.467)

    
    static let divider     = Color(hex: "#1C3050") ?? Color(red: 0.110, green: 0.188, blue: 0.314)
    static let outlineCyan = Color(hex: "#1A3A55") ?? Color(red: 0.102, green: 0.227, blue: 0.333)

    /// Tab bar: inactive labels must stay readable on dark glass (not `textMutedOnDark` — too dim).
    static let tabBarLabelInactive = Color(hex: "#9ECAE8") ?? Color(red: 0.62, green: 0.79, blue: 0.91)
}



struct ILGradient {
    static let splashTop    = ILTheme.background
    static let splashBottom = ILTheme.backgroundTertiary

    static func vertical(_ top: Color, _ bottom: Color) -> LinearGradient {
        LinearGradient(colors: [top, bottom], startPoint: .top, endPoint: .bottom)
    }

    static let amberAccent = LinearGradient(
        colors: [ILTheme.amber, ILTheme.amberDark],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}



struct ILCardModifier: ViewModifier {
    var elevated: Bool = false
    var glassIntensity: Double = 1.0
    @Environment(\.ilRewardAccent) private var accent

    func body(content: Content) -> some View {
        let base = elevated ? ILTheme.backgroundElevated : ILTheme.backgroundSecondary
        content
            .background(
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: ILTheme.iceLight.opacity(0.06 * glassIntensity), location: 0),
                                    .init(color: base.opacity(0.98), location: 0.15),
                                    .init(color: base.opacity(0.88), location: 1),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial.opacity(0.4 * glassIntensity))
                        .environment(\.colorScheme, .dark)
                    
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18 * glassIntensity),
                                    Color.white.opacity(0.05 * glassIntensity),
                                    Color.clear,
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                        .padding(0.5)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                accent.light.opacity(0.55 * glassIntensity),
                                accent.mid.opacity(0.25 * glassIntensity),
                                ILTheme.outlineCyan.opacity(0.8 * glassIntensity),
                                ILTheme.divider.opacity(0.9),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
                    .shadow(color: accent.light.opacity(0.25 * glassIntensity), radius: 8, x: 0, y: 0)
            )
            .shadow(color: .black.opacity(0.55), radius: 18, x: 0, y: 8)
            .shadow(color: accent.mid.opacity(0.18), radius: 32, x: 0, y: 12)
    }
}

extension View {
    func ilCard(elevated: Bool = false) -> some View {
        modifier(ILCardModifier(elevated: elevated))
    }

    func ilGlassTextShadow() -> some View {
        modifier(ILGlassTextShadow())
    }

    /// Hides system List/Form background so the atmosphere shows through.
    @ViewBuilder func ilScrollSurface() -> some View {
        self.scrollContentBackground(.hidden)
    }
}

private struct ILGlassTextShadow: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    func body(content: Content) -> some View {
        if reduceTransparency {
            content
        } else {
            content.shadow(color: .black.opacity(0.55), radius: 2, x: 0, y: 1)
        }
    }
}



extension Font {
    /// Editorial / splash / hero titles — distinct from rounded UI chrome.
    static func ilPolarSerif(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    static func ilDisplay(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    static func ilBody(_ size: CGFloat = 15, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func ilCaption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
}



extension Color {
    init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let n = UInt32(s, radix: 16) else { return nil }
        let r = Double((n >> 16) & 0xFF) / 255
        let g = Double((n >> 8)  & 0xFF) / 255
        let b = Double(n         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
