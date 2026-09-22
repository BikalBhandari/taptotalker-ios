import SwiftUI
import UIKit

@main
struct TapToTalkerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appModel)
                .tint(AACTheme.accent)
                .preferredColorScheme(.light)
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
                .onAppear {
                    OrientationLock.lockLandscape()
                }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        .landscape
    }
}

enum OrientationLock {
    static func lockLandscape() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first
        else { return }

        let prefs = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscape)
        scene.requestGeometryUpdate(prefs) { _ in }

        // Nudge any stuck portrait presentation after launch.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            scene.requestGeometryUpdate(prefs) { _ in }
        }
    }
}
