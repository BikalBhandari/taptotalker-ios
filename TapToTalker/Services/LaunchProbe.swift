import Foundation

#if DEBUG
enum LaunchProbe {
    private static let start = CFAbsoluteTimeGetCurrent()

    static func mark(_ label: String) {
        let ms = (CFAbsoluteTimeGetCurrent() - start) * 1000
        print(String(format: "[TapToTalker Launch] +%.0fms  %@", ms, label))
    }
}
#else
enum LaunchProbe {
    static func mark(_ label: String) {}
}
#endif
