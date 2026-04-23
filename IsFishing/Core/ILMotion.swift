import SwiftUI

/// Shared motion tokens so transitions feel like one product.
enum ILMotion {
    static let tabSwitch = Animation.spring(response: 0.32, dampingFraction: 0.84)
    static let snap = Animation.spring(response: 0.38, dampingFraction: 0.72)
    static let soft = Animation.spring(response: 0.45, dampingFraction: 0.88)
    static let gentle = Animation.spring(response: 0.55, dampingFraction: 0.9)
    static let cardPress = Animation.spring(response: 0.28, dampingFraction: 0.68)
    static let splashStage = Animation.easeInOut(duration: 0.35)
}

struct ILPressScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(ILMotion.cardPress, value: configuration.isPressed)
    }
}

extension View {
    func ilPressScaleButton(_ scale: CGFloat = 0.97) -> some View {
        buttonStyle(ILPressScaleButtonStyle(scale: scale))
    }

    /// Staggered fade/slide for list rows (index 0…n).
    func ilStaggeredAppear(index: Int, baseDelay: Double = 0.04) -> some View {
        modifier(ILStaggeredAppearModifier(index: index, baseDelay: baseDelay))
    }
}

private struct ILStaggeredAppearModifier: ViewModifier {
    let index: Int
    let baseDelay: Double
    @State private var visible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 10)
            .onAppear {
                if reduceMotion {
                    visible = true
                } else {
                    let d = baseDelay * Double(index)
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.86).delay(d)) {
                        visible = true
                    }
                }
            }
    }
}
