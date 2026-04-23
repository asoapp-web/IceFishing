import Combine
import SwiftUI

struct ILSplashScreen: View {
    let onFinished: () -> Void

    @State private var arcProgress: CGFloat = 0
    @State private var iconScale: CGFloat = 0.45
    @State private var iconOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 22
    @State private var stageOpacity: Double = 0
    @State private var ringRotation: Double = 0
    @State private var ringPulse: CGFloat = 1.0
    @State private var innerRingRotation: Double = 0
    @State private var fishSwim: CGFloat = 0
    @State private var bubblePhase: Double = 0
    @State private var startTime: Date?
    @State private var didCallFinish = false
    @State private var hapticMilestones: Set<Int> = []

    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let minSplashDuration: TimeInterval = 3.5
    private let finishHold: TimeInterval = 0.38

    var body: some View {
        ZStack {
            
            ILAtmosphereBackground()
            
            
            if !reduceMotion {
                SplashParticles()
            }

            
            TimelineView(.animation(minimumInterval: 1.0 / 24.0, paused: reduceMotion)) { ctx in
                let t = ctx.date.timeIntervalSinceReferenceDate
                ILSplashIceCanvas(time: t, reduceMotion: reduceMotion)
                    .opacity(0.85)
            }

            VStack(spacing: 0) {
                Spacer()

                
                ZStack {
                    if !reduceMotion {
                        
                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        accent.light.opacity(0.6),
                                        accent.mid.opacity(0.25),
                                        Color.clear,
                                        accent.light.opacity(0.5),
                                    ],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 2, dash: [6, 10])
                            )
                            .frame(width: 180, height: 180)
                            .rotationEffect(.degrees(ringRotation))

                        
                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        ILTheme.iceLight.opacity(0.3),
                                        accent.light.opacity(0.15),
                                        ILTheme.iceLight.opacity(0.3),
                                    ],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 1.5, dash: [8, 8])
                            )
                            .frame(width: 156, height: 156)
                            .rotationEffect(.degrees(-innerRingRotation))

                        
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        accent.light.opacity(0.12),
                                        accent.mid.opacity(0.05),
                                        .clear,
                                    ],
                                    center: .center,
                                    startRadius: 60,
                                    endRadius: 90
                                )
                            )
                            .frame(width: 176, height: 176)
                            .scaleEffect(ringPulse)
                            .blur(radius: 20)

                        
                        ForEach(0..<4) { i in
                            SplashFish(
                                index: i,
                                time: bubblePhase,
                                accent: accent
                            )
                        }
                    }

                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ILTheme.backgroundTertiary,
                                    ILTheme.backgroundElevated,
                                    ILTheme.backgroundTertiary,
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 142, height: 142)
                        .shadow(color: .black.opacity(0.4), radius: 8, y: 4)

                    
                    Circle()
                        .trim(from: 0, to: arcProgress)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    accent.light,
                                    ILTheme.cyanLight,
                                    accent.mid,
                                    accent.dark,
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 142, height: 142)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: accent.mid.opacity(0.6), radius: 12, x: 0, y: 0)

                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "#C8E4F0")?.opacity(0.95) ?? ILTheme.iceLight.opacity(0.95),
                                    Color(hex: "#7EB8D4")?.opacity(0.8) ?? ILTheme.iceLight.opacity(0.8),
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 65
                            )
                        )
                        .frame(width: 124, height: 124)
                        .overlay(
                            
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            accent.dark.opacity(0.85),
                                            ILTheme.background.opacity(0.98),
                                        ],
                                        center: .center,
                                        startRadius: 5,
                                        endRadius: 55
                                    )
                                )
                                .frame(width: 96, height: 96)
                                .overlay(
                                    
                                    Circle()
                                        .trim(from: 0, to: arcProgress)
                                        .stroke(
                                            LinearGradient(
                                                colors: [accent.light, ILTheme.cyanLight],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                                        )
                                        .rotationEffect(.degrees(-90))
                                        .frame(width: 92, height: 92)
                                        .shadow(color: accent.light.opacity(0.6), radius: 4)
                                )
                        )

                    
                    ZStack {
                        
                        Circle()
                            .fill(accent.light.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .blur(radius: 15)
                            .opacity(0.6 + Double(arcProgress) * 0.4)

                        Image(systemName: "fish.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        ILTheme.frostWhite,
                                        accent.light,
                                        accent.mid,
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: accent.mid.opacity(0.7), radius: 10)
                    }
                    .offset(y: 24 - arcProgress * 44)
                    .opacity(0.4 + Double(arcProgress) * 0.6)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)

                Spacer().frame(height: 40)

                
                VStack(spacing: 10) {
                    Text("Is Fishing")
                        .font(.ilPolarSerif(38, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    ILTheme.frostWhite,
                                    ILTheme.iceLight,
                                    accent.light.opacity(0.95),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black.opacity(0.6), radius: 0, y: 2)
                        .shadow(color: accent.mid.opacity(0.35), radius: 20, y: 5)

                    Text("Ice Fishing Companion")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [accent.light.opacity(0.9), ILTheme.cyanLight.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .tracking(1)
                }
                .opacity(titleOpacity)
                .offset(y: titleOffset)

                Spacer()

                
                VStack(spacing: 10) {
                    Text(ilSplashStageTitle(progress: arcProgress))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .id("t-\(ilSplashStageBucket(progress: arcProgress))")
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(y: 10)),
                            removal: .opacity
                        ))
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: ilSplashStageBucket(progress: arcProgress))

                    Text(ilSplashStageDetail(progress: arcProgress))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [accent.light.opacity(0.9), ILTheme.cyanLight.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .id("d-\(ilSplashStageBucket(progress: arcProgress))")
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(y: 8)),
                            removal: .opacity
                        ))
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: ilSplashStageBucket(progress: arcProgress))

                    
                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(ILTheme.backgroundTertiary)
                                .overlay(
                                    Capsule()
                                        .stroke(ILTheme.divider.opacity(0.5), lineWidth: 0.5)
                                )

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            accent.dark,
                                            accent.light,
                                            ILTheme.cyanLight,
                                            accent.light,
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(12, g.size.width * arcProgress))
                                .shadow(color: accent.light.opacity(0.4), radius: 8, y: 0)

                            
                            if arcProgress > 0 && arcProgress < 1 {
                                LinearGradient(
                                    colors: [.clear, Color.white.opacity(0.4), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(width: 40)
                                .offset(x: g.size.width * arcProgress - 40)
                                .opacity(0.7)
                            }
                        }
                    }
                    .frame(height: 10)
                    .padding(.horizontal, 44)

                    Text("\(Int(min(arcProgress, 1) * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [accent.light, ILTheme.cyanLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .monospacedDigit()
                        .shadow(color: accent.light.opacity(0.3), radius: 4)
                }
                .opacity(stageOpacity)

                Spacer().frame(height: 80)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .statusBarHidden(true)
        .onAppear {
            startTime = Date()
            runIntroMotion()
        }
        .onReceive(Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()) { _ in
            guard let startTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)

            if reduceMotion {
                arcProgress = 1
                tryHaptics(for: arcProgress)
                guard !didCallFinish, elapsed >= minSplashDuration else { return }
                didCallFinish = true
                ILHaptics.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + finishHold) {
                    onFinished()
                }
                return
            }

            guard !didCallFinish else { return }

            withAnimation(.linear(duration: 0.03)) {
                arcProgress = ilSplashComputedProgress(elapsed: elapsed)
                bubblePhase = elapsed
            }
            tryHaptics(for: arcProgress)
            tryFinishIfNeeded(elapsed: elapsed)
        }
    }

    /// One bucket per ~10% so copy tracks visible percentage closely.
    private func ilSplashStageBucket(progress: CGFloat) -> Int {
        min(9, Int(min(progress, 1) * 100) / 10)
    }

    private func ilSplashStageTitle(progress: CGFloat) -> String {
        switch ilSplashStageBucket(progress: progress) {
        case 0: return "Preparing gear..."
        case 1: return "Checking ice thickness..."
        case 2: return "Drilling holes..."
        case 3: return "Setting up lines..."
        case 4: return "Loading species data..."
        case 5: return "Warming up maps..."
        case 6: return "Organizing sessions..."
        case 7: return "Calibrating games..."
        case 8: return "Final checks..."
        default: return "Ready to fish!"
        }
    }

    private func ilSplashStageDetail(progress: CGFloat) -> String {
        switch ilSplashStageBucket(progress: progress) {
        case 0: return "Gathering tackle box"
        case 1: return "Ensuring safe conditions"
        case 2: return "Creating access points"
        case 3: return "Attaching lures"
        case 4: return "100+ species catalog"
        case 5: return "Your saved spots"
        case 6: return "Trip history ready"
        case 7: return "Mini-games loaded"
        case 8: return "Almost there"
        default: return "Let's catch some fish"
        }
    }

    private func ilSplashComputedProgress(elapsed: TimeInterval) -> CGFloat {
        let p = elapsed / minSplashDuration
        
        let eased = p < 0.5 
            ? 2 * p * p 
            : 1 - pow(-2 * p + 2, 2) / 2
        return min(1, max(0, CGFloat(eased)))
    }

    private func tryHaptics(for progress: CGFloat) {
        let bucket = ilSplashStageBucket(progress: progress) * 10
        guard !hapticMilestones.contains(bucket), bucket > 0 else { return }
        hapticMilestones.insert(bucket)
        if bucket % 20 == 0 {
            ILHaptics.heavy()
        } else {
            ILHaptics.medium()
        }
    }

    private func tryFinishIfNeeded(elapsed: TimeInterval) {
        guard elapsed >= minSplashDuration + finishHold else { return }
        didCallFinish = true
        ILHaptics.success()
        DispatchQueue.main.async {
            onFinished()
        }
    }

    private func runIntroMotion() {
        guard !reduceMotion else {
            iconScale = 1
            iconOpacity = 1
            titleOpacity = 1
            titleOffset = 0
            stageOpacity = 1
            return
        }

        
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
        withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
            innerRingRotation = 360
        }
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            ringPulse = 1.15
        }

        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            iconScale = 1
            iconOpacity = 1
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.15)) {
            titleOpacity = 1
            titleOffset = 0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            stageOpacity = 1
        }
    }
}


private struct SplashFish: View {
    let index: Int
    let time: Double
    let accent: ILRewardAccent
    
    private var angle: Double {
        Double(index) / 4.0 * 2.0 * .pi + time * 0.3
    }
    
    private var radius: CGFloat {
        85 + CGFloat(sin(time + Double(index)) * 15)
    }
    
    private var fishX: CGFloat {
        CGFloat(cos(angle)) * radius
    }
    
    private var fishY: CGFloat {
        CGFloat(sin(angle)) * radius * 0.6
    }
    
    private var opacity: Double {
        0.15 + sin(time * 2 + Double(index)) * 0.1
    }
    
    private var rotation: Double {
        angle * 180 / .pi + 90
    }
    
    var body: some View {
        Image(systemName: "fish.fill")
            .font(.system(size: 14 + CGFloat(index) * 2, weight: .medium))
            .foregroundStyle(accent.light.opacity(opacity))
            .offset(x: fishX, y: fishY)
            .rotationEffect(.degrees(rotation))
    }
}


private struct SplashParticles: View {
    @Environment(\.ilRewardAccent) private var accent
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                drawCrystals(context: context, size: size, time: t, accent: accent)
                drawSparkles(context: context, size: size, time: t)
            }
            .allowsHitTesting(false)
        }
    }
    
    private func drawCrystals(context: GraphicsContext, size: CGSize, time: Double, accent: ILRewardAccent) {
        for i in 0..<8 {
            let idx = Double(i)
            let angle = idx / 8.0 * 2.0 * .pi + time * 0.1
            let radius: CGFloat = 140 + CGFloat(sin(time * 0.5 + idx) * 30)
            let x = size.width / 2 + CGFloat(cos(angle)) * radius
            let y = size.height / 2 + CGFloat(sin(angle)) * radius * 0.5
            let crystalSize: CGFloat = 8 + CGFloat(i % 3) * 3
            let rotation = time * 50 + idx * 45
            
            let path = makeHexagon(x: x, y: y, size: crystalSize, rotation: rotation)
            
            context.fill(path, with: .color(accent.light.opacity(0.08)))
            context.stroke(path, with: .color(accent.light.opacity(0.15)), lineWidth: 0.8)
        }
    }
    
    private func drawSparkles(context: GraphicsContext, size: CGSize, time: Double) {
        for i in 0..<15 {
            let idx = Double(i)
            let sx = size.width * (0.2 + CGFloat(sin(time * 0.3 + idx) * 0.3 + 0.3))
            let sy = size.height * (0.3 + CGFloat(cos(time * 0.2 + idx * 1.3) * 0.2 + 0.2))
            let sparkle = sin(time * 3 + idx) * 0.5 + 0.5
            
            context.fill(
                Path(ellipseIn: CGRect(x: sx, y: sy, width: 1.5, height: 1.5)),
                with: .color(ILTheme.iceLight.opacity(sparkle * 0.6))
            )
        }
    }
    
    private func makeHexagon(x: CGFloat, y: CGFloat, size: CGFloat, rotation: Double) -> Path {
        var path = Path()
        for j in 0..<6 {
            let a = Double(j) * (.pi / 3) - .pi / 2 + rotation * .pi / 180
            let px = x + CGFloat(cos(a)) * size * 0.4
            let py = y + CGFloat(sin(a)) * size * 0.4
            if j == 0 {
                path.move(to: CGPoint(x: px, y: py))
            } else {
                path.addLine(to: CGPoint(x: px, y: py))
            }
        }
        path.closeSubpath()
        return path
    }
}
