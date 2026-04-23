import SwiftUI

/// Full-screen arctic atmosphere: deep navy base, animated aurora orbs,
/// swimming fish, floating particles, ice sheen, edge vignette, subtle film grain.
/// Living background with continuous ambient animations.
struct ILAtmosphereBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                if reduceTransparency {
                    ILTheme.background
                } else {
                    ILAtmosphereBaseLayer(size: size)

                    if reduceMotion {
                        ILAtmosphereGlowLayer(size: size, breath: 1.0)
                        ILAtmosphereSheen(size: size, t: 0)
                    } else {
                        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { ctx in
                            let t = ctx.date.timeIntervalSinceReferenceDate
                            let breath = 0.91 + 0.09 * CGFloat(sin(t * 0.38))
                            let drift  = CGFloat(sin(t * 0.24)) * 10
                            ZStack {
                                ILAtmosphereGlowLayer(size: size, breath: breath, drift: drift)
                                ILAtmosphereSheen(size: size, t: t)
                            }
                        }
                    }

                    ILBorealStarField(reduceMotion: reduceMotion)
                    
                    
                    if !reduceMotion {
                        ILAmbientEffects()
                        SwimmingFishLayer(size: size)
                    }
                    
                    ILAtmosphereVignette(size: size)
                    ILFilmGrainOverlay()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}



private struct ILAtmosphereBaseLayer: View {
    let size: CGSize
    @Environment(\.ilRewardAccent) private var accent
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "#040A12") ?? ILTheme.background, location: 0),
                    .init(color: Color(hex: "#080E1A") ?? ILTheme.background, location: 0.25),
                    .init(color: Color(hex: "#0A1422") ?? ILTheme.background, location: 0.55),
                    .init(color: Color(hex: "#0C1830") ?? ILTheme.background, location: 0.80),
                    .init(color: Color(hex: "#071020") ?? ILTheme.background, location: 1.0),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            RadialGradient(
                colors: [accent.light.opacity(0.07), Color.clear],
                center: .init(x: 0.15, y: 0.12),
                startRadius: 10,
                endRadius: min(size.width, size.height) * 0.55
            )
            
            RadialGradient(
                colors: [ILTheme.backgroundTertiary.opacity(0.50), Color.clear],
                center: .init(x: 0.88, y: 0.82),
                startRadius: 20,
                endRadius: min(size.width, size.height) * 0.52
            )
        }
        .allowsHitTesting(false)
    }
}



private struct ILAtmosphereGlowLayer: View {
    let size: CGSize
    var breath: CGFloat
    var drift: CGFloat = 0
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        ZStack {
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            accent.light.opacity(0.45),
                            accent.mid.opacity(0.22),
                            accent.mid.opacity(0.08),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                )
                .frame(width: 440, height: 440)
                .scaleEffect(breath)
                .offset(x: size.width * 0.22 + drift * 0.25, y: -size.height * 0.14)
                .blur(radius: 70)
                .allowsHitTesting(false)

            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#0A2848")?.opacity(0.90) ?? ILTheme.backgroundTertiary.opacity(0.90),
                            accent.dark.opacity(0.15),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 170
                    )
                )
                .frame(width: 340, height: 340)
                .scaleEffect(1.85 - breath * 0.06)
                .offset(x: -size.width * 0.26 - drift * 0.18, y: size.height * 0.30)
                .blur(radius: 55)
                .allowsHitTesting(false)

            
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [accent.mid.opacity(0.18), Color.clear],
                        center: .center, startRadius: 0, endRadius: 120
                    )
                )
                .frame(width: 250, height: 90)
                .offset(x: drift * 0.10, y: size.height * 0.28)
                .blur(radius: 38)
                .allowsHitTesting(false)

            
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [accent.light.opacity(0.16), Color.clear],
                        center: .center, startRadius: 0, endRadius: 110
                    )
                )
                .frame(width: 220, height: 88)
                .offset(x: drift * 0.08, y: -size.height * 0.12)
                .blur(radius: 32)
                .allowsHitTesting(false)
        }
    }
}



private struct ILAtmosphereSheen: View {
    let size: CGSize
    let t: TimeInterval
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        let shift = CGFloat(sin(t * 0.22)) * 22
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        accent.light.opacity(0.10),
                        accent.mid.opacity(0.05),
                        Color.clear,
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            )
            .frame(width: size.width * 1.6, height: 190)
            .rotationEffect(.degrees(-28))
            .offset(x: size.width * 0.18 + shift, y: -size.height * 0.08)
            .blur(radius: 48)
            .blendMode(.plusLighter)
            .opacity(0.55)
            .allowsHitTesting(false)
    }
}



private struct ILBorealStarField: View {
    let reduceMotion: Bool
    @Environment(\.ilRewardAccent) private var accent

    var body: some View {
        if reduceMotion {
            Canvas { _, _ in }
                .allowsHitTesting(false)
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 18.0)) { ctx in
                let t = ctx.date.timeIntervalSinceReferenceDate
                Canvas { ctx2, sz in
                    let seeds: [CGFloat] = [0.12, 0.22, 0.31, 0.44, 0.53, 0.61, 0.72, 0.81, 0.88, 0.15, 0.67, 0.39, 0.58, 0.91, 0.05, 0.47, 0.76, 0.33, 0.19, 0.84, 0.62, 0.41, 0.28, 0.95, 0.07, 0.51, 0.73, 0.36, 0.89, 0.24, 0.56, 0.68, 0.14, 0.77, 0.42, 0.99, 0.08, 0.63, 0.45, 0.29, 0.86, 0.18, 0.54, 0.37, 0.71, 0.93, 0.11, 0.64, 0.82, 0.46]
                    for (i, sx) in seeds.enumerated() {
                        let sy = seeds[(i + 7) % seeds.count]
                        let x = sx * sz.width
                        let y = sy * sz.height * 0.72
                        let tw = 0.35 + 0.65 * (0.5 + 0.5 * sin(t * 1.3 + Double(i) * 0.7))
                        let r: CGFloat = i % 4 == 0 ? 1.8 : 1.1
                        ctx2.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                            with: .color(accent.light.opacity(0.08 + tw * 0.14))
                        )
                    }
                }
                .blendMode(.plusLighter)
                .opacity(0.85)
                .allowsHitTesting(false)
            }
        }
    }
}



private struct ILAtmosphereVignette: View {
    let size: CGSize
    var body: some View {
        RadialGradient(
            colors: [Color.clear, Color.black.opacity(0.55)],
            center: .center,
            startRadius: 60,
            endRadius: max(size.width, size.height) * 0.86
        )
        .blendMode(.multiply)
        .allowsHitTesting(false)
    }
}



private struct SwimmingFishLayer: View {
    let size: CGSize
    
    var body: some View {
        ZStack {
            
            SilhouetteFish(
                size: 24,
                y: size.height * 0.25,
                duration: 18,
                delay: 0,
                width: size.width
            )
            SilhouetteFish(
                size: 18,
                y: size.height * 0.35,
                duration: 24,
                delay: 6,
                width: size.width
            )
            SilhouetteFish(
                size: 20,
                y: size.height * 0.20,
                duration: 20,
                delay: 12,
                width: size.width,
                reverse: true
            )
            
            ForEach(0..<4) { i in
                SilhouetteFish(
                    size: 10,
                    y: size.height * 0.28 + CGFloat(i) * 15,
                    duration: 15 + Double(i) * 3,
                    delay: Double(i) * 3,
                    width: size.width
                )
            }
            
            
            ForEach(0..<5) { i in
                let crystalSize = CGFloat(16 + (i % 3) * 12)
                let minX: CGFloat = 50
                let maxX = max(minX, size.width - 50)
                let minY: CGFloat = 50
                let maxY = max(minY, size.height - 100)
                
                FloatingIceCrystal(
                    size: crystalSize,
                    x: CGFloat.random(in: minX...maxX),
                    y: CGFloat.random(in: minY...maxY),
                    duration: Double(12 + (i % 4) * 4)
                )
            }
        }
    }
}

private struct SilhouetteFish: View {
    let size: CGFloat
    let y: CGFloat
    let duration: Double
    let delay: Double
    let width: CGFloat
    var reverse: Bool = false
    
    @State private var x: CGFloat = -50
    @State private var wobble: CGFloat = 0
    
    var body: some View {
        Canvas { context, _ in
            
            var bodyPath = Path()
            bodyPath.move(to: CGPoint(x: size * 0.7, y: 0))
            bodyPath.addCurve(
                to: CGPoint(x: -size * 0.5, y: 0),
                control1: CGPoint(x: size * 0.3, y: -size * 0.3),
                control2: CGPoint(x: -size * 0.2, y: -size * 0.3)
            )
            bodyPath.addCurve(
                to: CGPoint(x: size * 0.7, y: 0),
                control1: CGPoint(x: -size * 0.2, y: size * 0.3),
                control2: CGPoint(x: size * 0.3, y: size * 0.3)
            )
            
            
            var tailPath = Path()
            tailPath.move(to: CGPoint(x: -size * 0.4, y: 0))
            tailPath.addLine(to: CGPoint(x: -size * 0.8, y: -size * 0.2 + wobble))
            tailPath.addLine(to: CGPoint(x: -size * 0.8, y: size * 0.2 + wobble))
            tailPath.closeSubpath()
            
            context.fill(bodyPath, with: .color(ILTheme.cyanLight.opacity(0.12)))
            context.fill(tailPath, with: .color(ILTheme.cyanLight.opacity(0.08)))
        }
        .frame(width: size * 1.8, height: size)
        .position(x: x, y: y + wobble * 0.5)
        .onAppear {
            x = reverse ? width + 50 : -50
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    x = reverse ? -50 : width + 50
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    wobble = 8
                }
            }
        }
    }
}

private struct FloatingIceCrystal: View {
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
    let duration: Double
    
    @State private var rotation: Double = 0
    @State private var float: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        Canvas { context, _ in
            
            var path = Path()
            for i in 0..<6 {
                let angle = Double(i) * (.pi / 3) - .pi / 2
                let px = size * 0.5 + cos(angle) * size * 0.4
                let py = size * 0.5 + sin(angle) * size * 0.4
                if i == 0 {
                    path.move(to: CGPoint(x: px, y: py))
                } else {
                    path.addLine(to: CGPoint(x: px, y: py))
                }
            }
            path.closeSubpath()
            
            context.fill(path, with: .color(ILTheme.cyanLight.opacity(0.06)))
            context.stroke(path, with: .color(ILTheme.cyanLight.opacity(0.2)), lineWidth: 0.8)
        }
        .frame(width: size, height: size)
        .position(x: x, y: y + float)
        .opacity(opacity)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: duration * 0.5).repeatForever(autoreverses: true)) {
                float = 20
            }
            withAnimation(.easeIn(duration: 1)) {
                opacity = 0.7
            }
        }
    }
}



private struct ILFilmGrainOverlay: View {
    var body: some View {
        Canvas { ctx, size in
            let step: CGFloat = 14
            var x: CGFloat = 0
            while x < size.width + step {
                var y: CGFloat = 0
                while y < size.height + step {
                    let h = UInt32(bitPattern: Int32(bitPattern: UInt32(x) &* 2654435761 &+ UInt32(y) &* 2246822519))
                    let n = (h ^ (h >> 16)) & 0xFF
                    let o = 0.008 + Double(n) / 255.0 * 0.030
                    ctx.fill(
                        Path(CGRect(x: x, y: y, width: 1.2, height: 1.2)),
                        with: .color(.white.opacity(o))
                    )
                    y += step
                }
                x += step
            }
        }
        .blendMode(.overlay)
        .opacity(0.55)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
