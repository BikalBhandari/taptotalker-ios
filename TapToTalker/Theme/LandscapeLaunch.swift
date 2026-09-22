import UIKit

enum LandscapeLaunch {
    private static var lastEnforceAt: TimeInterval = 0

    /// Request landscape geometry when the window scene is available.
    /// On iPad Simulator, also rely on the Xcode scheme pre-action
    /// (Device → Orientation → Landscape Right) before Run.
    static func enforce(reason: String) {
        _ = reason
        let now = ProcessInfo.processInfo.systemUptime
        // Coalesce bursty activate/appear calls during launch.
        if now - lastEnforceAt < 0.4 { return }
        lastEnforceAt = now

        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first
        else { return }

        scene.requestGeometryUpdate(
            .iOS(interfaceOrientations: .landscape)
        ) { _ in }

        scene.windows.forEach {
            $0.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
}
