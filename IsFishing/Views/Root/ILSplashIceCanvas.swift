import SwiftUI

/// Procedural ice shards + frost specks — splash-only decoration.
struct ILSplashIceCanvas: View {
    let time: TimeInterval
    let reduceMotion: Bool

    var body: some View {
        Canvas { ctx, size in
            let accent = Color(hex: "#38E0F5") ?? ILTheme.cyanLight
            let t = reduceMotion ? 0 : time

            for i in 0..<14 {
                let seed = Double(i) * 1.618
                let x = size.width * (0.08 + CGFloat(sin(seed * 2.1) * 0.35 + 0.35))
                let y = size.height * (0.12 + CGFloat(cos(seed * 1.7) * 0.38 + 0.38))
                let rot = CGFloat(t * (0.35 + seed * 0.02) + seed)
                let w: CGFloat = 6 + CGFloat(i % 4) * 2
                let h: CGFloat = 14 + CGFloat((i * 3) % 5) * 2

                var diamond = Path()
                diamond.move(to: CGPoint(x: 0, y: -h / 2))
                diamond.addLine(to: CGPoint(x: w * 0.35, y: 0))
                diamond.addLine(to: CGPoint(x: 0, y: h / 2))
                diamond.addLine(to: CGPoint(x: -w * 0.35, y: 0))
                diamond.closeSubpath()

                var tf = CGAffineTransform(translationX: x, y: y)
                tf = tf.rotated(by: reduceMotion ? 0 : rot)
                ctx.concatenate(tf)
                ctx.fill(diamond, with: .color(accent.opacity(0.07 + Double(i % 5) * 0.01)))
                ctx.stroke(diamond, with: .color(accent.opacity(0.14)), lineWidth: 0.5)
                ctx.concatenate(tf.inverted())
            }

            for i in 0..<28 {
                let seed = Double(i) * 0.913
                let drift = reduceMotion ? 0 : sin(t * 0.45 + seed) * 12
                let x = size.width * CGFloat((sin(seed * 4) * 0.5 + 0.5))
                var y = size.height * CGFloat((cos(seed * 3) * 0.5 + 0.5)) + drift
                y = y.truncatingRemainder(dividingBy: size.height)
                if y < 0 { y += size.height }
                let r: CGFloat = 0.8 + CGFloat(i % 3) * 0.35
                let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                ctx.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(0.04 + Double(i % 4) * 0.015)))
            }
        }
        .allowsHitTesting(false)
    }
}
