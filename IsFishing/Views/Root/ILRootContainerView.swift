import SwiftUI

struct ILRootContainerView: View {
    @StateObject private var store = ILPersistenceStore.shared
    @StateObject private var router = ILAppRouter()
    @State private var splashActive: Bool
    @State private var showOnboarding: Bool

    init() {
        let mocks = ILScreenshotMockData.isEnabled
        _splashActive = State(initialValue: !mocks)
        _showOnboarding = State(initialValue: false)
    }

    var body: some View {
        Group {
            if splashActive {
                ILSplashScreen {
                    splashActive = false
                    showOnboarding = !store.onboardingCompletedFlag
                }
            } else if showOnboarding {
                ILOnboardingFlow(isPresented: $showOnboarding)
                    .environmentObject(store)
            } else {
                ILMainShellView()
                    .environmentObject(store)
                    .environmentObject(router)
            }
        }
        .onChange(of: showOnboarding) { _, new in
            if new == false { store.reloadFromDefaults() }
        }
        .onChange(of: store.onboardingCompletedFlag) { _, completed in
            if !completed { showOnboarding = true }
        }
        .environment(\.ilRewardAccent, ILRewardAccent(theme: store.activeRewardTheme))
    }
}
