import SwiftUI

@main
struct TapToTalkerApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appModel)
                .tint(Color(red: 0.15, green: 0.45, blue: 0.72))
        }
    }
}
