import SwiftUI
import Combine


/// Powerful visual effects for mini-games - particles, glows, animations


struct IcePullEffects: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let phase: IcePullPhase
    let tension: CGFloat
    let progress: CGFloat
    let isHolding: Bool
    let inGreen: Bool
    let inRed: Bool
    
    enum IcePullPhase { case waiting, bite, reeling, ended }
    
    var body: some View {
        ZStack {
            if !reduceMotion {
                
                UnderwaterAmbience()
                
                
                RisingBubbles(phase: phase, progress: progress)
                
                
                if phase == .reeling {
                    TensionParticles(tension: tension, inGreen: inGreen, inRed: inRed)
                }
                
                
                if phase == .ended && progress >= 1.0 {
                    SuccessBurst()
                }
                
                
                if phase == .bite {
                    BiteFlashEffect()
                }
            }
        }
    }
}

private struct UnderwaterAmbience: View {
    @State private var offset: CGFloat = 0
    
    var body: some View {
        Canvas { context, size in
            
            for i in 0..<8 {
                let y = CGFloat(i) * (size.height / 8) + offset
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                
                for x in stride(from: 0, to: size.width, by: 10) {
                    let wave = sin(Double(x) * 0.02 + Double(i)) * 3
                    path.addLine(to: CGPoint(x: x, y: y + CGFloat(wave)))
                }
                
                context.stroke(path, with: .color(ILTheme.cyanLight.opacity(0.03)), lineWidth: 1)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                offset = 20
            }
        }
    }
}

private struct RisingBubbles: View {
    let phase: IcePullEffects.IcePullPhase
    let progress: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                BubbleParticle(
                    index: i,
                    speed: Double(3 + i % 5),
                    size: CGFloat(3 + i % 4),
                    intensity: phase == .reeling ? 1.5 : 0.7
                )
            }
        }
    }
}

private struct BubbleParticle: View {
    let index: Int
    let speed: Double
    let size: CGFloat
    let intensity: Double
    
    @State private var y: CGFloat = 0
    @State private var x: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        ILTheme.iceLight.opacity(0.5 * intensity),
                        ILTheme.iceLight.opacity(0.1 * intensity),
                        .clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size
                )
            )
            .frame(width: size * 2, height: size * 2)
            .position(x: x, y: y)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                resetPosition()
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.3) {
                    animate()
                }
            }
    }
    
    private func resetPosition() {
        y = UIScreen.main.bounds.height + 50
        x = CGFloat.random(in: 30...(UIScreen.main.bounds.width - 30))
        opacity = Double.random(in: 0.3...0.7)
        scale = 0.5
    }
    
    private func animate() {
        withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
            y = -50
            x += CGFloat.random(in: -30...30)
        }
        withAnimation(.easeInOut(duration: speed * 0.5).repeatForever(autoreverses: true)) {
            scale = 1.2
        }
    }
}

private struct TensionParticles: View {
    let tension: CGFloat
    let inGreen: Bool
    let inRed: Bool
    
    @State private var phase: Double = 0
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { _ in
            Canvas { context, size in
                let particleCount = inRed ? 30 : (inGreen ? 15 : 8)
                let baseColor = inRed ? Color.red : (inGreen ? ILTheme.semanticSuccess : ILTheme.cyanLight)
                
                for i in 0..<particleCount {
                    let angle = Double(i) / Double(particleCount) * 2.0 * .pi + phase
                    let radius: CGFloat = 60 + CGFloat(sin(phase + Double(i))) * 20
                    let x = size.width / 2 + cos(angle) * radius
                    let y = size.height / 2 + sin(angle) * radius
                    let particleSize: CGFloat = inRed ? 3 : 2
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: particleSize, height: particleSize)),
                        with: .color(baseColor.opacity(0.6))
                    )
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 2.0 * .pi
                }
            }
        }
    }
}

private struct SuccessBurst: View {
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            
            ForEach(0..<3) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [ILTheme.semanticSuccess, ILTheme.cyanLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 100 + CGFloat(i) * 40, height: 100 + CGFloat(i) * 40)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotationEffect(.degrees(rotation))
            }
            
            
            ForEach(0..<12) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ILTheme.semanticSuccess)
                    .offset(
                        x: cos(Double(i) / 12.0 * 2.0 * .pi) * 80,
                        y: sin(Double(i) / 12.0 * 2.0 * .pi) * 80
                    )
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotationEffect(.degrees(rotation * 2))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.5
            }
            withAnimation(.easeOut(duration: 1)) {
                opacity = 0
                rotation = 180
            }
        }
    }
}

private struct BiteFlashEffect: View {
    @State private var flash: Bool = false
    
    var body: some View {
        Color.white
            .opacity(flash ? 0.3 : 0)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
                    flash.toggle()
                }
            }
    }
}


struct MarkedCatchEffects: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let score: Int
    let combo: Int
    let timeRemaining: Double
    let isPlaying: Bool
    
    var body: some View {
        ZStack {
            if !reduceMotion && isPlaying {
                
                IceSurfaceEffect()
                
                
                if combo > 2 {
                    ComboGlowEffect(combo: combo)
                }
                
                
                if timeRemaining < 5 {
                    TimePressureEffect()
                }
                
                
                FallingSnow()
            }
        }
    }
}

private struct IceSurfaceEffect: View {
    @State private var shimmer: CGFloat = 0
    
    var body: some View {
        Canvas { context, size in
            
            for i in 0..<5 {
                var path = Path()
                let startX = CGFloat.random(in: 0...size.width)
                let startY = CGFloat.random(in: 0...size.height)
                path.move(to: CGPoint(x: startX, y: startY))
                
                for _ in 0..<5 {
                    path.addLine(to: CGPoint(
                        x: startX + CGFloat.random(in: -50...50),
                        y: startY + CGFloat.random(in: -50...50)
                    ))
                }
                
                context.stroke(path, with: .color(ILTheme.iceLight.opacity(0.04)), lineWidth: 1)
            }
        }
        .overlay(
            
            LinearGradient(
                colors: [.clear, ILTheme.iceLight.opacity(0.1), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: shimmer)
            .blendMode(.screen)
        )
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmer = 200
            }
        }
    }
}

private struct ComboGlowEffect: View {
    let combo: Int
    @State private var pulse: CGFloat = 1
    @State private var glow: CGFloat = 0
    
    var body: some View {
        ZStack {
            
            ForEach(0..<min(combo, 5), id: \.self) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                ILTheme.amber.opacity(0.8 - Double(i) * 0.15),
                                ILTheme.cyanLight.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 150 + CGFloat(i) * 30, height: 150 + CGFloat(i) * 30)
                    .scaleEffect(pulse)
                    .opacity(0.6 - glow * 0.3)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                pulse = 1.3
                glow = 1
            }
        }
    }
}

private struct TimePressureEffect: View {
    @State private var flash: Bool = false
    
    var body: some View {
        Color.red
            .opacity(flash ? 0.08 : 0)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    flash.toggle()
                }
            }
    }
}

private struct FallingSnow: View {
    @State private var particles: [SnowParticle] = []
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { _ in
            Canvas { context, size in
                for particle in particles {
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: particle.x,
                            y: particle.y,
                            width: particle.size,
                            height: particle.size
                        )),
                        with: .color(ILTheme.iceLight.opacity(particle.opacity))
                    )
                }
            }
            .onAppear {
                createParticles(in: UIScreen.main.bounds.size)
            }
        }
    }
    
    private func createParticles(in size: CGSize) {
        particles = (0..<30).map { i in
            SnowParticle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: (-100)...size.height),
                size: CGFloat.random(in: 2...5),
                speed: CGFloat.random(in: 30...80),
                opacity: Double.random(in: 0.3...0.7),
                sway: Double.random(in: 0...2 * .pi)
            )
        }
        
        
        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            for i in particles.indices {
                particles[i].y += particles[i].speed / 60.0
                particles[i].x += sin(particles[i].sway) * 0.5
                particles[i].sway += 0.05
                
                if particles[i].y > size.height + 10 {
                    particles[i].y = -10
                    particles[i].x = CGFloat.random(in: 0...size.width)
                }
            }
        }
    }
}

private struct SnowParticle {
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speed: CGFloat
    var opacity: Double
    var sway: Double
}


struct TargetPopEffect: View {
    let position: CGPoint
    let isBomb: Bool
    let onComplete: () -> Void
    
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 1
    @State private var ringScale: CGFloat = 1
    
    var body: some View {
        ZStack {
            
            Circle()
                .stroke(
                    isBomb ? Color.red : ILTheme.semanticSuccess,
                    lineWidth: 2
                )
                .frame(width: 60, height: 60)
                .scaleEffect(ringScale)
                .opacity(opacity * 0.5)
            
            
            Circle()
                .fill(
                    isBomb 
                        ? AnyShapeStyle(Color.red.opacity(0.8))
                        : AnyShapeStyle(
                            LinearGradient(
                                colors: [ILTheme.semanticSuccess, ILTheme.cyanLight],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                )
                .frame(width: 40, height: 40)
                .scaleEffect(scale)
                .opacity(opacity)
            
            
            if !isBomb {
                ForEach(0..<6) { i in
                    Image(systemName: "sparkle")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ILTheme.semanticSuccess)
                        .offset(
                            x: cos(Double(i) / 6.0 * 2.0 * .pi) * 30,
                            y: sin(Double(i) / 6.0 * 2.0 * .pi) * 30
                        )
                        .scaleEffect(scale)
                        .opacity(opacity)
                }
            }
        }
        .position(position)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                scale = 1.5
                ringScale = 2
            }
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete()
            }
        }
    }
}


struct GameButtonStyle: ButtonStyle {
    @Environment(\.ilRewardAccent) private var accent
    let color: Color
    let isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .brightness(configuration.isPressed ? -0.1 : 0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}


struct AnimatedScoreCounter: View {
    let score: Int
    let oldScore: Int
    
    @State private var displayScore: Int = 0
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Text("\(displayScore)")
            .font(.system(size: 48, weight: .heavy, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [ILTheme.frostWhite, ILTheme.iceLight],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: ILTheme.cyanLight.opacity(0.5), radius: 10)
            .scaleEffect(scale)
            .onAppear {
                displayScore = oldScore
            }
            .onChange(of: score) { _, newValue in
                animateToScore(newValue)
            }
    }
    
    private func animateToScore(_ target: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = 1.2
        }
        
        
        let diff = target - displayScore
        let steps = min(abs(diff), 20)
        let stepValue = diff / steps
        
        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                displayScore += stepValue
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(steps) * 0.02 + 0.1) {
            displayScore = target
            withAnimation(.spring(response: 0.3)) {
                scale = 1
            }
        }
    }
}
