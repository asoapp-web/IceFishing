import SwiftUI


/// Living background with swimming fish - ambient animation always running
struct ILFishTankBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                LinearGradient(
                    colors: [
                        Color(hex: "#051020") ?? ILTheme.background,
                        Color(hex: "#0A1A2E") ?? ILTheme.backgroundSecondary,
                        Color(hex: "#0D2038") ?? ILTheme.backgroundTertiary,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                
                if !reduceMotion {
                    LightRays()
                }
                
                
                if !reduceMotion {
                    FishLayer(width: geo.size.width, height: geo.size.height)
                }
                
                
                if !reduceMotion {
                    BubblesLayer(width: geo.size.width, height: geo.size.height)
                }
                
                
                if !reduceMotion {
                    ParticlesLayer()
                }
                
                
                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [.clear, ILTheme.background.opacity(0.3), ILTheme.background.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)
                }
                .ignoresSafeArea()
            }
        }
    }
}


private struct LightRays: View {
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0.3
    
    var body: some View {
        Canvas { context, size in
            let rayCount = 5
            for i in 0..<rayCount {
                let angle = (Double(i) / Double(rayCount)) * .pi * 0.4 - .pi * 0.2 + rotation * 0.02
                var path = Path()
                let startX = size.width * 0.5 + CGFloat(sin(angle)) * 100
                path.move(to: CGPoint(x: startX, y: -50))
                path.addLine(to: CGPoint(x: startX + CGFloat(sin(angle + 0.1)) * size.height * 0.8, 
                                        y: size.height * 0.6))
                path.addLine(to: CGPoint(x: startX + CGFloat(sin(angle - 0.1)) * size.height * 0.8, 
                                        y: size.height * 0.6))
                path.closeSubpath()
                
                context.fill(path, with: .color(.white.opacity(0.03 + Double(i) * 0.01)))
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                opacity = 0.5
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}


private struct FishLayer: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            
            SwimmingFish(
                color: ILTheme.cyanLight.opacity(0.6),
                size: 30,
                path: .sinusoidal,
                duration: 15,
                delay: 0,
                width: width,
                height: height
            )
            
            SwimmingFish(
                color: ILTheme.iceLight.opacity(0.4),
                size: 24,
                path: .straight,
                duration: 20,
                delay: 3,
                width: width,
                height: height
            )
            
            SwimmingFish(
                color: ILTheme.cyan.opacity(0.5),
                size: 28,
                path: .wave,
                duration: 18,
                delay: 6,
                width: width,
                height: height
            )
            
            SwimmingFish(
                color: Color(hex: "#7EB8D4")?.opacity(0.45) ?? ILTheme.iceLight.opacity(0.4),
                size: 22,
                path: .sinusoidal,
                duration: 25,
                delay: 9,
                width: width,
                height: height
            )
            
            
            ForEach(0..<5) { i in
                SwimmingFish(
                    color: ILTheme.cyanLight.opacity(0.25),
                    size: 12,
                    path: .straight,
                    duration: 12 + Double(i) * 2,
                    delay: Double(i) * 1.5,
                    width: width,
                    height: height,
                    yOffset: CGFloat(i) * 40 - 80
                )
            }
        }
    }
}


private enum FishPath {
    case sinusoidal, straight, wave
}

private struct SwimmingFish: View {
    let color: Color
    let size: CGFloat
    let path: FishPath
    let duration: Double
    let delay: Double
    let width: CGFloat
    let height: CGFloat
    var yOffset: CGFloat = 0
    
    @State private var position: CGFloat = -100
    @State private var wobble: CGFloat = 0
    @State private var tailWag: Double = 0
    
    var body: some View {
        Canvas { context, _ in
            
            var bodyPath = Path()
            bodyPath.move(to: CGPoint(x: size * 0.8, y: 0))
            bodyPath.addCurve(
                to: CGPoint(x: -size * 0.6, y: 0),
                control1: CGPoint(x: size * 0.4, y: -size * 0.35),
                control2: CGPoint(x: -size * 0.2, y: -size * 0.35)
            )
            bodyPath.addCurve(
                to: CGPoint(x: size * 0.8, y: 0),
                control1: CGPoint(x: -size * 0.2, y: size * 0.35),
                control2: CGPoint(x: size * 0.4, y: size * 0.35)
            )
            
            
            var tailPath = Path()
            let tailOffset = sin(tailWag) * size * 0.15
            tailPath.move(to: CGPoint(x: -size * 0.5, y: 0))
            tailPath.addLine(to: CGPoint(x: -size * 0.9, y: -size * 0.25 + tailOffset))
            tailPath.addLine(to: CGPoint(x: -size * 0.9, y: size * 0.25 + tailOffset))
            tailPath.closeSubpath()
            
            
            var finPath = Path()
            finPath.move(to: CGPoint(x: size * 0.1, y: -size * 0.2))
            finPath.addLine(to: CGPoint(x: -size * 0.15, y: -size * 0.45))
            finPath.addLine(to: CGPoint(x: -size * 0.05, y: -size * 0.2))
            
            context.fill(bodyPath, with: .color(color))
            context.fill(tailPath, with: .color(color.opacity(0.8)))
            context.fill(finPath, with: .color(color.opacity(0.6)))
            
            
            context.fill(
                Path(ellipseIn: CGRect(x: size * 0.35, y: -size * 0.1, width: size * 0.12, height: size * 0.12)),
                with: .color(.white.opacity(0.8))
            )
            context.fill(
                Path(ellipseIn: CGRect(x: size * 0.38, y: -size * 0.07, width: size * 0.06, height: size * 0.06)),
                with: .color(.black.opacity(0.6))
            )
        }
        .frame(width: size * 2, height: size)
        .position(x: position, y: height * 0.3 + yOffset + wobble)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    position = width + 100
                }
                
                
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    wobble = 30
                }
                
                
                withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                    tailWag = .pi
                }
            }
        }
    }
}


private struct BubblesLayer: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(0..<15) { i in
                Bubble(
                    size: CGFloat(4 + (i % 4) * 3),
                    x: CGFloat.random(in: 0...width),
                    speed: Double(8 + (i % 5) * 3),
                    delay: Double(i) * 0.8,
                    height: height
                )
            }
        }
    }
}

private struct Bubble: View {
    let size: CGFloat
    let x: CGFloat
    let speed: Double
    let delay: Double
    let height: CGFloat
    
    @State private var y: CGFloat = 0
    @State private var wobble: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ILTheme.iceLight.opacity(0.4),
                            ILTheme.iceLight.opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(ILTheme.iceLight.opacity(0.3), lineWidth: 0.5)
                )
        }
        .position(x: x + wobble, y: y)
        .opacity(opacity)
        .onAppear {
            y = height + 50
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                    y = -50
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    wobble = CGFloat.random(in: -20...20)
                }
                withAnimation(.easeIn(duration: 0.5)) {
                    opacity = Double.random(in: 0.3...0.7)
                }
            }
        }
    }
}


private struct ParticlesLayer: View {
    @State private var phase: Double = 0
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { _ in
            Canvas { context, size in
                let particleCount = 30
                for i in 0..<particleCount {
                    let t = Double(i) / Double(particleCount)
                    let x = CGFloat(t * Double(size.width) + sin(phase + Double(i)) * 50)
                    let y = CGFloat(Double(i % 10) / 10.0 * Double(size.height) + cos(phase + Double(i) * 0.5) * 30)
                    let particleSize = CGFloat(1 + (i % 3))
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: particleSize, height: particleSize)),
                        with: .color(ILTheme.iceLight.opacity(0.15 + Double(i % 5) * 0.05))
                    )
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    phase = .pi * 2
                }
            }
        }
    }
}


struct ILGlassModifier: ViewModifier {
    @Environment(\.ilRewardAccent) private var accent
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                    
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    ILTheme.iceLight.opacity(0.08),
                                    ILTheme.cyanLight.opacity(0.04),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                accent.light.opacity(0.3),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
            .shadow(color: accent.light.opacity(0.1), radius: 30, y: 15)
    }
}

extension View {
    func ilGlass() -> some View {
        modifier(ILGlassModifier())
    }
}
