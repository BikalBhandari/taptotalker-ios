import Foundation

struct AACCard: Identifiable, Hashable, Sendable {
    let id: String
    let label: String
    let emoji: String
    let prompt: String?
    let minMode: VocabularyMode?
    let options: [AACCard]

    init(
        id: String,
        label: String,
        emoji: String,
        prompt: String? = nil,
        minMode: VocabularyMode? = nil,
        options: [AACCard] = []
    ) {
        self.id = id
        self.label = label
        self.emoji = emoji
        self.prompt = prompt
        self.minMode = minMode
        self.options = options
    }

    var isLeaf: Bool { options.isEmpty }

    func visible(for mode: VocabularyMode) -> Bool {
        guard let minMode else { return true }
        return mode.rank >= minMode.rank
    }

    func filtered(for mode: VocabularyMode) -> AACCard {
        AACCard(
            id: id,
            label: label,
            emoji: emoji,
            prompt: prompt,
            minMode: minMode,
            options: options
                .filter { $0.visible(for: mode) }
                .map { $0.filtered(for: mode) }
        )
    }
}

struct CustomCardOverride: Codable, Hashable, Sendable {
    var label: String?
    var emoji: String?
    /// Relative filename under Documents/CustomCardImages, if any.
    var imageFileName: String?
}

struct BoardNode: Sendable {
    let prompt: String
    let options: [AACCard]
}
