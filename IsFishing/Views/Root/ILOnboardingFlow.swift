import SwiftUI

struct ILOnboardingFlow: View {
    @Binding var isPresented: Bool
    @State private var page = 0
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pages = 4

    var body: some View {
        ZStack {
            
            ILAtmosphereBackground()
            
            
            if !reduceMotion {
                OnboardingParticleField()
            }

            ILOnboardingAmbientDrift()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if page < pages - 1 {
                        Button {
                            ILHaptics.light()
                            withAnimation(ILMotion.snap) {
                                page = pages - 1
                            }
                        } label: {
                            Text("Skip")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [accent.light, ILTheme.iceLight],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(ILTheme.backgroundElevated.opacity(0.6))
                                        .overlay(Capsule().stroke(accent.light.opacity(0.3), lineWidth: 1))
                                )
                        }
                        .ilPressScaleButton(0.96)
                        .padding()
                    }
                }

                TabView(selection: $page) {
                    onboardingPage(
                        hero: .welcome,
                        title: "Is Fishing",
                        subtitle: "Your offline-first ice fishing companion",
                        body: "Guides, species, map pins, and trip log — built for cold mornings and long seasons."
                    )
                    .tag(0)

                    onboardingPage(
                        hero: .learn,
                        title: "Learn & identify",
                        subtitle: "Guides + species library",
                        body: "Safety, gear, and tactics in readable articles. Browse 100+ real species with photos — no signal required."
                    )
                    .tag(1)

                    onboardingPage(
                        hero: .map,
                        title: "Map & memory",
                        subtitle: "Pins on your terms",
                        body: "Long-press anywhere to save a spot. Search places when you're online. Tap a pin to open the spot card, then edit details or add photos when you want."
                    )
                    .tag(2)

                    getStartedPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(reduceMotion ? .default : ILMotion.gentle, value: page)

                pageDots
                    .padding(.bottom, 12)

                if page < pages - 1 {
                    Button {
                        ILHaptics.light()
                        withAnimation(ILMotion.snap) {
                            page = min(page + 1, pages - 1)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("Continue")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [accent.light, accent.mid, accent.dark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: accent.mid.opacity(0.55), radius: 20, y: 8)
                        )
                    }
                    .ilPressScaleButton(0.98)
                    .ilFloat(range: 3, duration: 3)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
            }
        }
    }

    private var pageDots: some View {
        HStack(spacing: 10) {
            ForEach(0..<pages, id: \.self) { i in
                Capsule()
                    .fill(
                        i == page 
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [accent.light, accent.mid],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            : AnyShapeStyle(ILTheme.divider)
                    )
                    .frame(width: i == page ? 32 : 8, height: 8)
                    .shadow(color: i == page ? accent.light.opacity(0.6) : .clear, radius: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: page)
                    .overlay(
                        Group {
                            if i == page {
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            }
                        }
                    )
            }
        }
    }

    private func onboardingPage(
        hero: ILOnboardingHeroKind,
        title: String,
        subtitle: String,
        body: String
    ) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                ZStack {
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [accent.light.opacity(0.15), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .blur(radius: 40)
                        .ilBreathingGlow()
                    
                    ILOnboardingHero(kind: hero)
                        .padding(.top, 8)
                        .id(hero)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.9)),
                            removal: .opacity
                        ))
                }
                .frame(height: 220)

                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    ILTheme.backgroundElevated.opacity(0.92),
                                    ILTheme.backgroundSecondary.opacity(0.88),
                                    ILTheme.background.opacity(0.95),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(.ultraThinMaterial.opacity(0.5))
                        .environment(\.colorScheme, .dark)
                    
                    
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05),
                                    Color.clear,
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                        .padding(0.5)

                    
                    VStack(spacing: 18) {
                        Text(title)
                            .font(.ilPolarSerif(32, weight: .heavy))
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
                            .multilineTextAlignment(.center)
                            .shadow(color: accent.light.opacity(0.3), radius: 12, x: 0, y: 0)

                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [accent.light, accent.mid],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 60, height: 4)
                            .shadow(color: accent.light.opacity(0.5), radius: 6)

                        Text(subtitle)
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(accent.light.opacity(0.95))
                            .multilineTextAlignment(.center)
                            .tracking(0.5)

                        Text(body)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(ILTheme.textSecondaryOnDark)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(4)
                            .padding(.horizontal, 8)
                    }
                    .padding(28)
                }
                .padding(.horizontal, 20)
                .overlay(
                    
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    accent.light.opacity(0.45),
                                    accent.mid.opacity(0.2),
                                    ILTheme.divider.opacity(0.8),
                                    accent.light.opacity(0.1),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                        .padding(.horizontal, 20)
                )
                .shadow(color: .black.opacity(0.45), radius: 24, y: 12)
                .shadow(color: accent.mid.opacity(0.15), radius: 40, y: 16)
                .ilFloat(range: 5, duration: 4)

                Spacer(minLength: 36)
            }
        }
    }

    private var getStartedPage: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 26) {
                
                ZStack {
                    
                    ForEach(0..<12) { i in
                        Image(systemName: "sparkle")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [accent.light, ILTheme.cyanLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .offset(
                                x: cos(Double(i) / 12.0 * 2.0 * .pi) * 120,
                                y: sin(Double(i) / 12.0 * 2.0 * .pi) * 120
                            )
                            .ilFloat(range: 10, duration: 2 + Double(i) * 0.2)
                    }
                    
                    ILOnboardingHero(kind: .ready)
                        .padding(.top, 4)
                }
                .frame(height: 200)

                
                ZStack {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    ILTheme.backgroundElevated.opacity(0.94),
                                    ILTheme.backgroundSecondary.opacity(0.9),
                                    ILTheme.background.opacity(0.96),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(.ultraThinMaterial.opacity(0.5))
                        .environment(\.colorScheme, .dark)
                    
                    
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    ILTheme.semanticSuccess.opacity(0.5),
                                    accent.light.opacity(0.4),
                                    ILTheme.cyanLight.opacity(0.3),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )

                    VStack(spacing: 16) {
                        Text("You're set")
                            .font(.ilPolarSerif(32, weight: .heavy))
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
                            .shadow(color: accent.light.opacity(0.3), radius: 12)
                        
                        Text("Explore tabs at your pace. A small daily bonus appears when you open each section — look for the glowing dot on tab icons.")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(ILTheme.textSecondaryOnDark)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(28)
                }
                .padding(.horizontal, 20)
                .shadow(color: .black.opacity(0.45), radius: 24, y: 12)
                .shadow(color: ILTheme.semanticSuccess.opacity(0.15), radius: 32, y: 16)
                .ilFloat(range: 4, duration: 3.5)

                
                Button {
                    ILHaptics.success()
                    store.setOnboardingCompleted(true)
                    withAnimation(ILMotion.snap) {
                        isPresented = false
                    }
                } label: {
                    HStack(spacing: 10) {
                        Text("Enter Is Fishing")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 22))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        ILTheme.semanticSuccess,
                                        accent.light,
                                        accent.mid,
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: ILTheme.semanticSuccess.opacity(0.5), radius: 20, y: 8)
                    )
                }
                .ilPressScaleButton(0.98)
                .ilPulsingGlow()
                .padding(.horizontal, 24)

                Spacer(minLength: 50)
            }
        }
    }
}


private struct OnboardingParticleField: View {
    @Environment(\.ilRewardAccent) private var accent
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                
                for i in 0..<15 {
                    let seed = Double(i) * 0.77
                    let x = size.width * (0.1 + CGFloat(sin(seed + t * 0.06 + Double(i)) * 0.4 + 0.4))
                    let y = size.height * (0.05 + CGFloat(cos(seed * 1.1 + t * 0.05) * 0.42 + 0.42))
                    let r: CGFloat = 15 + CGFloat(i % 6) * 6
                    let o = 0.06 + Double(i % 5) * 0.02
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - r / 2, y: y - r / 2, width: r, height: r)),
                        with: .color(accent.light.opacity(o))
                    )
                }
                
                
                for i in 0..<20 {
                    let angle = Double(i) / 20.0 * 2.0 * .pi + t * 0.2
                    let radius: CGFloat = 80 + CGFloat(sin(t + Double(i)) * 40)
                    let x = size.width / 2 + cos(angle) * radius
                    let y = size.height * 0.4 + sin(angle) * radius * 0.5
                    let sparkle = sin(t * 2 + Double(i)) * 0.5 + 0.5
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)),
                        with: .color(ILTheme.iceLight.opacity(sparkle * 0.8))
                    )
                }
            }
            .allowsHitTesting(false)
            .blur(radius: 8)
        }
    }
}
