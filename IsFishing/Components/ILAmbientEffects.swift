import SwiftUI


/// Continuous ambient effects that run all the time - particles, sparkles, drift
struct ILAmbientEffects: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if !reduceMotion {
                    
                    DriftingSparkles(width: geo.size.width, height: geo.size.height)
                    
                    
                    FloatingCrystals(width: geo.size.width, height: geo.size.height)
                    
                    
                    GlowOrbs(width: geo.size.width, height: geo.size.height)
                }
            }
        }
    }
}


private struct DriftingSparkles: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0, paused: false)) { _ in
            Canvas { context, size in
                let sparkleCount = 25
                let time = Date().timeIntervalSinceReferenceDate
                
                for i in 0..<sparkleCount {
                    let t = fmod(time * 0.1 + Double(i) * 0.4, 2.0 * .pi)
                    let x = CGFloat(sin(t + Double(i)) * 0.5 + 0.5) * size.width
                    let y = CGFloat(fmod(time * 0.05 + Double(i) * 0.15, 1.0)) * size.height
                    let phase = fmod(time + Double(i) * 0.5, 1.0)
                    
                    let sparkleSize = CGFloat(2 + (i % 4))
                    let opacity = sin(phase * .pi) * 0.6
                    
                    
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: y - sparkleSize))
                    path.addLine(to: CGPoint(x: x, y: y + sparkleSize))
                    path.move(to: CGPoint(x: x - sparkleSize, y: y))
                    path.addLine(to: CGPoint(x: x + sparkleSize, y: y))
                    
                    context.stroke(path, with: .color(ILTheme.iceLight.opacity(opacity)), lineWidth: 1.5)
                    
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - 1, y: y - 1, width: 2, height: 2)),
                        with: .color(.white.opacity(opacity * 1.5))
                    )
                }
            }
        }
    }
}


private struct FloatingCrystals: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(0..<8) { i in
                FloatingCrystal(
                    size: CGFloat(20 + (i % 4) * 8),
                    x: CGFloat.random(in: 50...(width - 50)),
                    duration: Double(15 + (i % 6) * 5),
                    delay: Double(i) * 1.2,
                    height: height
                )
            }
        }
    }
}

private struct FloatingCrystal: View {
    let size: CGFloat
    let x: CGFloat
    let duration: Double
    let delay: Double
    let height: CGFloat
    
    @State private var y: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Canvas { context, _ in
            
            var path = Path()
            let points = 6
            for i in 0..<points {
                let angle = Double(i) * (2.0 * .pi / Double(points)) - .pi / 2
                let px = size * 0.5 + CGFloat(cos(angle)) * size * 0.4
                let py = size * 0.5 + CGFloat(sin(angle)) * size * 0.4
                if i == 0 {
                    path.move(to: CGPoint(x: px, y: py))
                } else {
                    path.addLine(to: CGPoint(x: px, y: py))
                }
            }
            path.closeSubpath()
            
            
            context.fill(path, with: .color(ILTheme.cyanLight.opacity(0.08)))
            context.stroke(path, with: .color(ILTheme.cyanLight.opacity(0.25)), lineWidth: 1)
            
            
            context.fill(
                Path(ellipseIn: CGRect(x: size * 0.45, y: size * 0.45, width: size * 0.1, height: size * 0.1)),
                with: .color(.white.opacity(0.6))
            )
        }
        .frame(width: size, height: size)
        .position(x: x, y: y)
        .opacity(opacity)
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            y = height + size
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    y = -size
                    rotation = 360
                }
                withAnimation(.easeInOut(duration: duration * 0.5).repeatForever(autoreverses: true)) {
                    scale = 1.1
                }
                withAnimation(.easeIn(duration: 0.8)) {
                    opacity = 0.6
                }
            }
        }
    }
}


private struct GlowOrbs: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(0..<5) { i in
                GlowOrb(
                    size: CGFloat(80 + (i % 3) * 60),
                    color: i % 2 == 0 ? ILTheme.cyan : ILTheme.cyanLight,
                    x: CGFloat.random(in: 100...(width - 100)),
                    y: CGFloat.random(in: 100...(height - 100)),
                    duration: Double(8 + (i % 4) * 3)
                )
            }
        }
    }
}

private struct GlowOrb: View {
    let size: CGFloat
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let duration: Double
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.2
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(0.25),
                        color.opacity(0.08),
                        .clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.5
                )
            )
            .frame(width: size, height: size)
            .position(x: x + offsetX, y: y + offsetY)
            .opacity(opacity)
            .scaleEffect(scale)
            .blur(radius: 20)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    scale = 1.2
                    opacity = 0.4
                }
                withAnimation(.easeInOut(duration: duration * 1.3).repeatForever(autoreverses: true)) {
                    offsetX = CGFloat.random(in: -40...40)
                    offsetY = CGFloat.random(in: -40...40)
                }
            }
    }
}


struct ILBreathingGlow: ViewModifier {
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    ZStack {
                        
                        if !reduceMotion {
                            Circle()
                                .stroke(accent.light.opacity(0.3), lineWidth: 1)
                                .frame(width: geo.size.width * 1.3, height: geo.size.height * 1.3)
                                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                                .modifier(BreathingAnimation())
                        }
                    }
                }
            )
    }
}

private struct BreathingAnimation: ViewModifier {
    @State private var scale: CGFloat = 0.9
    @State private var opacity: Double = 0.4
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    scale = 1.15
                    opacity = 0.7
                }
            }
    }
}

extension View {
    func ilBreathingGlow() -> some View {
        modifier(ILBreathingGlow())
    }
}


struct ILShimmer: ViewModifier {
    @State private var phase: CGFloat = -1
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.15), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: phase * geo.size.width)
                    .blendMode(.screen)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func ilShimmer() -> some View {
        modifier(ILShimmer())
    }
}


struct ILFloatingAnimation: ViewModifier {
    @State private var offset: CGFloat = 0
    let range: CGFloat
    let duration: Double
    
    init(range: CGFloat = 8, duration: Double = 3) {
        self.range = range
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    offset = -range
                }
            }
    }
}

extension View {
    func ilFloat(range: CGFloat = 8, duration: Double = 3) -> some View {
        modifier(ILFloatingAnimation(range: range, duration: duration))
    }
}


struct ILPulsingGlow: ViewModifier {
    @Environment(\.ilRewardAccent) private var accent
    @State private var pulse: CGFloat = 1
    @State private var glow: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .shadow(color: accent.light.opacity(0.5 + glow), radius: 10 + glow * 15, x: 0, y: 0)
            .scaleEffect(pulse)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    pulse = 1.02
                    glow = 0.3
                }
            }
    }
}

extension View {
    func ilPulsingGlow() -> some View {
        modifier(ILPulsingGlow())
    }
}
