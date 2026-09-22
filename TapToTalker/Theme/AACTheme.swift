import SwiftUI

enum CardTone: String, Hashable, Sendable, CaseIterable {
    case rose, amber, yellow, orange, emerald, teal, sky, indigo, violet, cyan

    /// Soft pastel fill with enough contrast for dark label text.
    var fill: Color {
        switch self {
        case .rose: return Color(red: 1.00, green: 0.88, blue: 0.90)
        case .amber: return Color(red: 1.00, green: 0.93, blue: 0.80)
        case .yellow: return Color(red: 1.00, green: 0.96, blue: 0.78)
        case .orange: return Color(red: 1.00, green: 0.90, blue: 0.82)
        case .emerald: return Color(red: 0.84, green: 0.95, blue: 0.88)
        case .teal: return Color(red: 0.82, green: 0.94, blue: 0.93)
        case .sky: return Color(red: 0.82, green: 0.92, blue: 1.00)
        case .indigo: return Color(red: 0.86, green: 0.88, blue: 0.98)
        case .violet: return Color(red: 0.92, green: 0.86, blue: 0.98)
        case .cyan: return Color(red: 0.80, green: 0.95, blue: 0.97)
        }
    }

    var stroke: Color {
        switch self {
        case .rose: return Color(red: 0.78, green: 0.35, blue: 0.42).opacity(0.35)
        case .amber: return Color(red: 0.78, green: 0.52, blue: 0.12).opacity(0.35)
        case .yellow: return Color(red: 0.72, green: 0.58, blue: 0.08).opacity(0.35)
        case .orange: return Color(red: 0.82, green: 0.42, blue: 0.16).opacity(0.35)
        case .emerald: return Color(red: 0.18, green: 0.55, blue: 0.34).opacity(0.35)
        case .teal: return Color(red: 0.12, green: 0.52, blue: 0.50).opacity(0.35)
        case .sky: return Color(red: 0.15, green: 0.45, blue: 0.72).opacity(0.35)
        case .indigo: return Color(red: 0.35, green: 0.35, blue: 0.72).opacity(0.35)
        case .violet: return Color(red: 0.52, green: 0.28, blue: 0.72).opacity(0.35)
        case .cyan: return Color(red: 0.10, green: 0.55, blue: 0.62).opacity(0.35)
        }
    }

    /// Deterministic tone from card id when none is assigned.
    static func inferred(for id: String) -> CardTone {
        let tones = CardTone.allCases
        let hash = abs(id.utf8.reduce(0) { ($0 &+ Int($1)) &* 31 })
        return tones[hash % tones.count]
    }
}

enum AACTheme {
    static let outerPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 24
    static let gridSpacing: CGFloat = 16
    static let cardCorner: CGFloat = 20
    static let minCardHeight: CGFloat = 128
    static let minTouch: CGFloat = 44

    /// Soft blue-gray so a failed/empty render never looks like a blank white flash.
    static let boardBackground = Color(red: 0.93, green: 0.95, blue: 0.98)
    static let accent = Color(red: 0.15, green: 0.45, blue: 0.72)
}
