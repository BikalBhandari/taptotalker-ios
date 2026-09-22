import SwiftUI

@main
struct TapToTalkerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appModel)
                .tint(Color(red: 0.15, green: 0.45, blue: 0.72))
                .background(AACTheme.boardBackground.ignoresSafeArea())
        }
    }
}
