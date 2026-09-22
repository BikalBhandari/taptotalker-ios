import SwiftUI
import UIKit

@main
struct TapToTalkerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var appModel = AppModel()

    init() {
        LaunchProbe.mark("TapToTalkerApp.init")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appModel)
                .tint(AACTheme.accent)
                .preferredColorScheme(.light)
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
                .onAppear {
                    LaunchProbe.mark("WindowGroup.onAppear")
                    // After first paint: disk settings + speech warm-up + orientation nudge.
                    DispatchQueue.main.async {
                        LaunchProbe.mark("first-frame callback")
                        appModel.bootstrapAfterFirstFrame()
                        OrientationLock.lockLandscape()
                    }
                }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        LaunchProbe.mark("AppDelegate.didFinishLaunching")
        return true
    }

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
    }
}
