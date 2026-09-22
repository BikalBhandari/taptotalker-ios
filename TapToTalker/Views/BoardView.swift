import SwiftUI

struct BoardView: View {
    @Environment(AppModel.self) private var app
    @Bindable var session: CommunicationSession

    let onEditCard: (AACCard) -> Void

    private var mode: VocabularyMode { app.vocabularyMode }
    private var node: BoardNode { session.currentNode(mode: mode) }
    private var options: [AACCard] { session.visibleOptions(mode: mode) }
    private var complete: Bool { session.isComplete(mode: mode) }
    private var phrase: String { session.phraseText(using: app) }
    private var maxSteps: Int { min(mode.maxSteps, max(session.pathIDs.count + (complete ? 0 : 1), 1)) }
    private var stepLabel: String {
        let current = min(session.pathIDs.count + (complete ? 0 : 1), mode.maxSteps)
        let total = min(mode.maxSteps, max(current, session.pathIDs.count + (options.isEmpty ? 0 : 1)))
        return "Step \(max(current, 1)) of \(max(total, 1))"
    }

    private var columns: [GridItem] {
        let count: Int
        switch mode {
        case .simple: count = min(options.count, 3)
        case .guided: count = min(options.count, 3)
        case .intermediate, .advanced: count = min(max(options.count, 1), 4)
        }
        return Array(repeating: GridItem(.flexible(), spacing: AACTheme.gridSpacing), count: max(count, 1))
    }

    var body: some View {
        VStack(spacing: 0) {
            PhraseBarView(
                phrase: phrase,
                stepLabel: stepLabel,
                prompt: node.prompt,
                isComplete: complete,
                canUndo: !session.pathIDs.isEmpty,
                onSpeak: { session.speakPhrase(using: app) },
                onClear: { session.reset() },
                onUndo: { session.undoLast() }
            )

            ScrollView {
                if complete {
                    completedState
                } else if options.isEmpty {
                    ContentUnavailableView(
                        "No more choices",
                        systemImage: "checkmark.bubble",
                        description: Text("Speak your phrase or clear to start again.")
                    )
                    .padding(AACTheme.sectionSpacing)
                } else {
                    LazyVGrid(columns: columns, spacing: AACTheme.gridSpacing) {
                        ForEach(options) { card in
                            AACCardButton(
                                title: app.displayLabel(for: card),
                                emoji: app.displayEmoji(for: card),
                                image: app.cardMode.usesCustomContent ? app.image(for: card.id) : nil,
                                isEditMode: app.cardMode == .edit,
                                action: {
                                    if !complete {
                                        session.select(card, app: app)
                                    }
                                },
                                onEdit: app.cardMode == .edit ? { onEditCard(card) } : nil
                            )
                            // Force refresh when overrides change
                            .id("\(card.id)-\(app.overridesVersion)-\(app.cardMode.rawValue)")
                        }
                    }
                    .padding(AACTheme.outerPadding)
                    .padding(.bottom, 32)
                }
            }
            .background(AACTheme.boardBackground)
        }
    }

    private var completedState: some View {
        VStack(spacing: 24) {
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("Message ready")
                .font(.largeTitle.weight(.bold))

            Text(phrase)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button {
                session.speakPhrase(using: app)
            } label: {
                Label("Speak phrase", systemImage: "speaker.wave.2.fill")
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: 360, minHeight: 56)
            }
            .buttonStyle(.borderedProminent)

            Button("Start over") {
                session.reset()
            }
            .font(.title3.weight(.semibold))
            .frame(minHeight: AACTheme.minTouch)
        }
        .frame(maxWidth: .infinity)
        .padding(AACTheme.sectionSpacing)
        .accessibilityElement(children: .contain)
    }
}
