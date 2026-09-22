import Foundation

enum VocabularyMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case simple
    case intermediate
    case guided
    case advanced

    var id: String { rawValue }

    var title: String {
        switch self {
        case .simple: return "Simple"
        case .intermediate: return "Intermediate"
        case .guided: return "Guided"
        case .advanced: return "Advanced"
        }
    }

    var detail: String {
        switch self {
        case .simple: return "5 home choices, up to 3 steps"
        case .intermediate: return "Up to 9 choices per screen, 3 steps"
        case .guided: return "6 choices per screen, up to 3 steps"
        case .advanced: return "Up to 9 choices per screen, detail cards, 4 steps"
        }
    }

    /// Rank used to filter `minMode` detail cards. Higher includes more detail.
    var rank: Int {
        switch self {
        case .simple: return 0
        case .intermediate, .guided: return 1
        case .advanced: return 2
        }
    }

    var maxSteps: Int {
        switch self {
        case .simple, .intermediate, .guided: return 3
        case .advanced: return 4
        }
    }

    /// Absolute max tiles on any board screen (keeps the grid readable on iPad).
    static let maxTilesPerScreen = 9

    /// Caps visible cards on the current screen.
    var screenLimit: Int {
        switch self {
        case .simple: return 5
        case .guided: return 6
        case .intermediate, .advanced: return Self.maxTilesPerScreen
        }
    }

    static func from(id: String) -> VocabularyMode {
        VocabularyMode(rawValue: id) ?? .intermediate
    }
}
