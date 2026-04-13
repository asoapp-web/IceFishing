import SwiftUI

extension View {
    /// Hides the main-shell custom tab bar while this view is visible (e.g. Profile → Statistics).
    func ilTracksProfileNavigationDepth(_ router: ILAppRouter) -> some View {
        self
            .onAppear { router.pushNestedProfile() }
            .onDisappear { router.popNestedProfile() }
    }
}
