import Combine
import Foundation
import SwiftUI

@MainActor
final class ILAppRouter: ObservableObject {
    @Published var selectedTab: Int = 0
    /// Primary hide flag: map editors, game screens, overlay covers.
    @Published var tabBarHidden: Bool = false
    /// Profile NavigationStack push depth (Statistics / Settings / Notes / Themes).
    @Published private(set) var nestedProfileDepth: Int = 0
    /// Session editor active — tab bar shows session-timer pulse animation.
    @Published var sessionEditorActive: Bool = false

    @Published var fullScreenOverlay: ILFullScreenOverlay?

    /// The tab bar should be visible only when nothing is hiding it.
    var tabBarShouldShow: Bool {
        !tabBarHidden && nestedProfileDepth == 0
    }

    func pushNestedProfile() {
        nestedProfileDepth += 1
    }

    func popNestedProfile() {
        nestedProfileDepth = max(0, nestedProfileDepth - 1)
    }

    func dismissFullScreenOverlay() {
        fullScreenOverlay = nil
        tabBarHidden = false
    }

    func openGuideArticle(id: String) {
        selectedTab = 0
        fullScreenOverlay = .guideArticle(id)
        tabBarHidden = true
    }

    func openSpeciesDetail(id: String) {
        selectedTab = 1
        fullScreenOverlay = .species(id)
        tabBarHidden = true
    }
}
