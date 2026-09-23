import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Soft board tint behind the first SwiftUI frame so launch never flashes white.
        UIWindow.appearance().backgroundColor = UIColor(
            red: 0.90,
            green: 0.94,
            blue: 0.97,
            alpha: 1
        )
        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        .all
    }
}
