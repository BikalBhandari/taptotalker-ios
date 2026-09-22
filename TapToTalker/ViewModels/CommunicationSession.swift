import Foundation
import Observation

@Observable
@MainActor
final class CommunicationSession {
    private(set) var pathIDs: [String] = []
    private let injectedSpeech: SpeechService?

    init(speech: SpeechService? = nil) {
        // Do not touch SpeechService.shared here — keeps launch free of AVFoundation.
        self.injectedSpeech = speech
        LaunchProbe.mark("CommunicationSession.init")
    }

    private var speech: SpeechService {
        injectedSpeech ?? SpeechService.shared
    }

    func reset() {
        pathIDs = []
    }

    func undoLast() {
        guard !pathIDs.isEmpty else { return }
        pathIDs.removeLast()
    }

    func select(_ card: AACCard, app: AppModel) {
        pathIDs.append(card.id)
        let spoken = app.displayLabel(for: card)
        speech.speak(spoken)
    }

    func speakPhrase(using app: AppModel) {
        speech.speak(phraseText(using: app))
    }

    func currentNode(mode: VocabularyMode) -> BoardNode {
        let root = DefaultVocabulary.root
        let filteredRoot = BoardNode(
            prompt: root.prompt,
            options: root.options
                .filter { $0.visible(for: mode) }
                .map { $0.filtered(for: mode) }
        )

        guard !pathIDs.isEmpty else { return filteredRoot }

        var node = filteredRoot
        var cards = filteredRoot.options
        for id in pathIDs {
            guard let match = cards.first(where: { $0.id == id }) else {
                return BoardNode(prompt: filteredRoot.prompt, options: [])
            }
            if match.options.isEmpty {
                return BoardNode(prompt: "Message ready", options: [])
            }
            node = BoardNode(prompt: match.prompt ?? "Choose next", options: match.options)
            cards = match.options
        }
        return node
    }

    func cardsOnPath(mode: VocabularyMode) -> [AACCard] {
        var result: [AACCard] = []
        var options = DefaultVocabulary.root.options
            .filter { $0.visible(for: mode) }
            .map { $0.filtered(for: mode) }

        for id in pathIDs {
            guard let match = options.first(where: { $0.id == id }) else { break }
            result.append(match)
            options = match.options
        }
        return result
    }

    func phraseText(using app: AppModel) -> String {
        cardsOnPath(mode: app.vocabularyMode)
            .map { app.displayLabel(for: $0) }
            .joined(separator: " ")
    }

    func maxSteps(for mode: VocabularyMode) -> Int {
        let depthCapacity = remainingDepthCapacity(mode: mode)
        let pathCount = pathIDs.count
        // Match web: min(mode.maxSteps, pathLength + remaining branch depth)
        return min(mode.maxSteps, max(pathCount, pathCount + depthCapacity))
    }

    func isComplete(mode: VocabularyMode) -> Bool {
        let node = currentNode(mode: mode)
        return pathIDs.count >= mode.maxSteps || node.options.isEmpty
    }

    func visibleOptions(mode: VocabularyMode) -> [AACCard] {
        let node = currentNode(mode: mode)
        let options = node.options
        guard let limit = mode.screenLimit else { return options }
        // Simple/Guided: limit only on the home (step 1) for Simple's 5 home choices;
        // Guided limits every screen to 6.
        if mode == .simple && !pathIDs.isEmpty {
            return options
        }
        return Array(options.prefix(limit))
    }

    private func remainingDepthCapacity(mode: VocabularyMode) -> Int {
        let node = currentNode(mode: mode)
        if node.options.isEmpty { return 0 }
        return 1 + (node.options.map { maxDepth($0) }.max() ?? 0)
    }

    private func maxDepth(_ card: AACCard) -> Int {
        if card.options.isEmpty { return 0 }
        return 1 + (card.options.map { maxDepth($0) }.max() ?? 0)
    }
}
