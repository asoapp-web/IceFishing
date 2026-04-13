import SwiftUI

struct ILMainShellView: View {
    @EnvironmentObject private var router: ILAppRouter
    @EnvironmentObject private var store: ILPersistenceStore
    @State private var toast: String?
    @State private var didRegisterLaunchTab = false

    private let bundleContent = ILBundleContentService.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch router.selectedTab {
                case 0:
                    ILGuideScreen(toast: $toast)
                case 1:
                    ILSpeciesScreen(toast: $toast)
                case 2:
                    ILMapScreen(toast: $toast)
                case 3:
                    ILSessionsScreen(toast: $toast)
                case 4:
                    ILGamesHubView(embeddedInTab: true)
                        .environmentObject(store)
                        .environmentObject(router)
                case 5:
                    ILProfileScreen(toast: $toast)
                default:
                    ILGuideScreen(toast: $toast)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if router.tabBarShouldShow {
                ILCustomTabBar(selected: $router.selectedTab)
                    .environmentObject(store)
                    .environmentObject(router)
            }
        }
        .ilToast($toast)
        .onChange(of: router.selectedTab) { _, _ in
            // When switching tabs away from Games, hub's onDisappear resets tabBarHidden.
            // Resetting here ensures it's cleared if the hub didn't fire onDisappear yet.
            if router.tabBarHidden && router.fullScreenOverlay == nil {
                router.tabBarHidden = false
            }
        }
        .fullScreenCover(item: Binding(
            get: { router.fullScreenOverlay },
            set: { new in
                router.fullScreenOverlay = new
                if new == nil { router.tabBarHidden = false }
            }
        )) { item in
            Group {
                switch item {
                case .guideArticle(let id):
                    if let article = bundleContent.article(by: id) {
                        ILArticleReader(
                            article: article,
                            onClose: { router.dismissFullScreenOverlay() },
                            onOpenRelatedArticle: { newId in
                                router.fullScreenOverlay = .guideArticle(newId)
                            }
                        )
                        .environmentObject(store)
                    } else {
                        Color.black
                            .ignoresSafeArea()
                            .onAppear { router.dismissFullScreenOverlay() }
                    }
                case .species(let id):
                    if let sp = bundleContent.species(by: id) {
                        ILSpeciesDetailSheet(
                            species: sp,
                            onClose: { router.dismissFullScreenOverlay() },
                            onOpenArticle: { aid in
                                router.fullScreenOverlay = .guideArticle(aid)
                            }
                        )
                        .environmentObject(store)
                    } else {
                        Color.black
                            .ignoresSafeArea()
                            .onAppear { router.dismissFullScreenOverlay() }
                    }
                }
            }
        }
        .onAppear {
            if !didRegisterLaunchTab {
                didRegisterLaunchTab = true
                store.registerMainTabVisit(router.selectedTab)
            }
        }
    }
}
