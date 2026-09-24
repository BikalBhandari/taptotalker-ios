import SwiftUI

enum AACTheme {
    static let outerPadding: CGFloat = 10
    static let sectionSpacing: CGFloat = 24
    static let gridSpacing: CGFloat = 12
    static let cardCorner: CGFloat = 26
    /// Absolute floor so AAC targets stay usable when the board compresses.
    static let minCardHeightFloor: CGFloat = 96
    static let minTouch: CGFloat = 44
    static let cardPadding: CGFloat = 16

    /// Soft cool tint — always behind content to avoid a white flash on launch.
    static let boardBackground = Color("BoardBackground")

    static let cardLabel = Color(red: 0.12, green: 0.16, blue: 0.22)
    static let accent = Color.accentColor

    /// Soft pastel fills keyed by AAC category / starter branch.
    static func cardFill(for cardID: String, pathRootID: String?) -> Color {
        let key = category(for: cardID) ?? pathRootID.flatMap { category(for: $0) } ?? .misc
        return pastel(for: key)
    }

    /// Prefer fewer, larger tiles (AAC-friendly). Caps columns so cards stay wide.
    /// Portrait defaults to 2 columns; landscape may use 3 when wide enough.
    /// Uses height when available so short canvases prefer more columns / fewer rows.
    static func columnCount(
        optionCount: Int,
        width: CGFloat,
        height: CGFloat = .infinity,
        mode: VocabularyMode
    ) -> Int {
        let isPortrait = height.isFinite && height > width
        let maxByWidth: Int
        if isPortrait {
            maxByWidth = 2
        } else if width >= 900 {
            maxByWidth = 3
        } else {
            maxByWidth = 2
        }

        let modeCap: Int
        switch mode {
        case .simple, .guided: modeCap = 3
        case .intermediate, .advanced: modeCap = 3
        }

        var cols = max(min(optionCount, modeCap, maxByWidth), 1)

        // If fixed mins would overflow the available height, widen the grid (more cols, fewer rows).
        if height.isFinite, height > 0, optionCount > 1 {
            while cols < min(optionCount, modeCap, 3) {
                let rows = Int(ceil(Double(optionCount) / Double(cols)))
                let spacing = CGFloat(max(rows - 1, 0)) * gridSpacing
                let available = height - spacing - outerPadding * 2
                let rowH = available / CGFloat(max(rows, 1))
                if rowH >= minCardHeightFloor { break }
                cols += 1
            }
        }

        return cols
    }

    private enum Category {
        case want, feel, need, people, answer, problem, see, hear
        case food, drink, places, play, help, rest, misc
    }

    private static func category(for id: String) -> Category? {
        switch id {
        case "want":
            return .want
        case "feel", "happy", "sad", "angry", "scared", "tired", "sick", "excited", "calm":
            return .feel
        case "need", "break", "medicine", "hug", "more", "finished":
            return .need
        case "person", "mom", "dad", "brother", "sister", "grandma", "grandpa",
             "friend", "teacher", "doctor", "caregiver":
            return .people
        case "answer", "yes", "no", "maybe", "stop", "again", "wait":
            return .answer
        case "not-okay", "pain", "hurt", "head", "tummy", "other", "stuck", "loud",
             "too-bright", "something-scary":
            return .problem
        case "see", "animal", "food", "toy", "screen":
            return .see
        case "hear", "voice", "music", "quiet", "my-name", "tv":
            return .hear
        case "eat", "cookies", "chicken", "nuggets", "strips", "wings", "sandwich",
             "chicken-sandwich", "pizza", "apple", "ice-cream", "vanilla", "chocolate",
             "strawberry":
            return .food
        case "drink", "water", "juice", "milk", "warm-drink", "ice", "no-ice", "small", "big":
            return .drink
        case "go", "bathroom", "outside", "car", "home", "chair", "walk", "park":
            return .places
        case "play", "game", "video-game", "board-game", "ball", "drawing", "read":
            return .play
        case "help", "talk":
            return .help
        case "sleep", "bed", "blanket", "pillow", "lights-off":
            return .rest
        default:
            return nil
        }
    }

    private static func pastel(for category: Category) -> Color {
        switch category {
        case .want: return Color(red: 1.00, green: 0.92, blue: 0.70)
        case .feel: return Color(red: 0.78, green: 0.93, blue: 0.82)
        case .need: return Color(red: 0.78, green: 0.88, blue: 0.98)
        case .people: return Color(red: 1.00, green: 0.88, blue: 0.78)
        case .answer: return Color(red: 0.88, green: 0.84, blue: 0.98)
        case .problem: return Color(red: 1.00, green: 0.84, blue: 0.82)
        case .see: return Color(red: 0.78, green: 0.94, blue: 0.92)
        case .hear: return Color(red: 0.86, green: 0.90, blue: 0.98)
        case .food: return Color(red: 1.00, green: 0.90, blue: 0.80)
        case .drink: return Color(red: 0.80, green: 0.93, blue: 0.98)
        case .places: return Color(red: 0.84, green: 0.94, blue: 0.88)
        case .play: return Color(red: 0.94, green: 0.86, blue: 0.98)
        case .help: return Color(red: 1.00, green: 0.86, blue: 0.90)
        case .rest: return Color(red: 0.90, green: 0.90, blue: 0.96)
        case .misc: return Color(red: 0.93, green: 0.94, blue: 0.96)
        }
    }
}
