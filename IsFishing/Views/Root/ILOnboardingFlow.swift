import SwiftUI

struct ILOnboardingFlow: View {
    @Binding var isPresented: Bool
    @State private var page = 0
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent

    private let pages = 4

    var body: some View {
        ZStack {
            ILAtmosphereBackground()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if page < pages - 1 {
                        Button("Skip") {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                                page = pages - 1
                            }
                        }
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(accent.light)
                        .padding()
                    }
                }

                TabView(selection: $page) {
                    onboardingCard(
                        title: "Is Fishing",
                        subtitle: "Your offline-first ice fishing companion",
                        body: "Guides, species, map pins, and trip log — built for cold mornings and long seasons.",
                        icon: "fish.fill"
                    ).tag(0)

                    onboardingCard(
                        title: "Learn & identify",
                        subtitle: "Guides + species library",
                        body: "Safety, gear, and tactics in readable articles. Browse 100+ real species with photos — no signal required.",
                        icon: "book.fill"
                    ).tag(1)

                    onboardingCard(
                        title: "Map & memory",
                        subtitle: "Pins on your terms",
                        body: "Long-press anywhere to save a spot. Search places when you’re online. Tap a pin to open the spot card, then edit details or add photos when you want.",
                        icon: "map.fill"
                    ).tag(2)

                    getStartedCard.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageDots
                    .padding(.bottom, 12)

                if page < pages - 1 {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                            page = min(page + 1, pages - 1)
                        }
                    } label: {
                        Text("Continue")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(ILTheme.textPrimaryOnLight)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [accent.light, accent.mid],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
            }
        }
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages, id: \.self) { i in
                Capsule()
                    .fill(i == page ? accent.light : ILTheme.divider)
                    .frame(width: i == page ? 22 : 7, height: 7)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: page)
            }
        }
    }

    private func onboardingCard(title: String, subtitle: String, body: String, icon: String) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(ILTheme.backgroundElevated.opacity(0.88))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [accent.light.opacity(0.4), ILTheme.divider],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.35), radius: 18, y: 8)

                    VStack(spacing: 18) {
                        Image(systemName: icon)
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [accent.light, accent.mid],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.top, 8)

                        Text(title)
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                            .multilineTextAlignment(.center)

                        Text(subtitle)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(accent.light.opacity(0.95))
                            .multilineTextAlignment(.center)

                        Text(body)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(ILTheme.textSecondaryOnDark)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 4)
                    }
                    .padding(26)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                Spacer(minLength: 40)
            }
        }
    }

    private var getStartedCard: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(ILTheme.backgroundElevated.opacity(0.88))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [accent.light.opacity(0.45), ILTheme.amber.opacity(0.25)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.35), radius: 18, y: 8)

                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(ILTheme.semanticSuccess)
                        Text("You’re set")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                        Text("Explore tabs at your pace. A small daily bonus appears when you open each section — check the orange dot on icons.")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(ILTheme.textSecondaryOnDark)
                            .multilineTextAlignment(.center)
                    }
                    .padding(26)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)

                Button {
                    store.setOnboardingCompleted(true)
                    isPresented = false
                } label: {
                    Text("Enter Is Fishing")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(ILTheme.textPrimaryOnLight)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [accent.light, accent.dark],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .padding(.horizontal, 24)
                Spacer(minLength: 50)
            }
        }
    }
}
