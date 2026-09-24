import SwiftUI

struct BoardView: View {
    @Environment(AppModel.self) private var app
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Bindable var session: CommunicationSession

    let onEditCard: (AACCard) -> Void

    private var mode: VocabularyMode { app.vocabularyMode }
    private var options: [AACCard] { session.visibleOptions(mode: mode) }
    private var complete: Bool { session.isComplete(mode: mode) }
    private var phrase: String { session.phraseText(using: app) }
    private var pathRootID: String? { session.pathIDs.first }
    private var isBuilding: Bool { !session.pathIDs.isEmpty && !complete }

    private let speakFill = Color(red: 0.78, green: 0.88, blue: 0.98)
    private let homeFill = Color(red: 0.84, green: 0.94, blue: 0.88)

    var body: some View {
        GeometryReader { geo in
            let phraseReserve: CGFloat = isBuilding ? 96 : 0
            let gridAvailableH = max(geo.size.height - phraseReserve, 0)
            let cols = AACTheme.columnCount(
                optionCount: options.count,
                width: geo.size.width,
                height: gridAvailableH,
                mode: mode
            )

            VStack(spacing: 0) {
                if isBuilding {
                    PhraseBarView(
                        phrase: phrase,
                        canClear: !session.pathIDs.isEmpty,
                        onClear: { session.reset() },
                        onSpeak: { session.speakPhrase(using: app) }
                    )
                }

                if complete {
                    completedState
                } else if options.isEmpty {
                    emptyState
                } else {
                    cardGrid(columnCount: cols)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(AACTheme.boardBackground)
        }
    }

    /// Equal flexible cells — cards expand to fill the board for large AAC targets.
    private func cardGrid(columnCount cols: Int) -> some View {
        let rows = Int(ceil(Double(options.count) / Double(max(cols, 1))))

        return VStack(spacing: AACTheme.gridSpacing) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: AACTheme.gridSpacing) {
                    ForEach(0..<cols, id: \.self) { col in
                        let index = row * cols + col
                        if index < options.count {
                            let card = options[index]
                            AACCardButton(
                                title: app.displayLabel(for: card),
                                emoji: app.displayEmoji(for: card),
                                fill: AACTheme.cardFill(for: card.id, pathRootID: pathRootID),
                                image: app.cardMode.usesCustomContent ? app.image(for: card.id) : nil,
                                isEditMode: app.cardMode == .edit,
                                action: {
                                    if !complete {
                                        session.select(card, app: app)
                                    }
                                },
                                onEdit: app.cardMode == .edit ? { onEditCard(card) } : nil
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .id("\(card.id)-\(app.overridesVersion)-\(app.cardMode.rawValue)")
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(AACTheme.outerPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var completedState: some View {
        VStack(spacing: AACTheme.gridSpacing) {
            VStack(spacing: 10) {
                Text("Message ready")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(AACTheme.cardLabel.opacity(0.7))

                Text(phrase)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(AACTheme.cardLabel)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.9))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(AACTheme.cardLabel.opacity(0.10), lineWidth: 1.5)
                    )
                    .accessibilityLabel("Message ready: \(phrase)")
            }
            .padding(.horizontal, AACTheme.outerPadding)
            .padding(.top, AACTheme.outerPadding)

            actionCards(
                includeSpeak: true,
                speakHint: "Speaks your finished message"
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
    }

    private var emptyState: some View {
        VStack(spacing: AACTheme.gridSpacing) {
            Text(phrase.isEmpty ? "No more choices" : phrase)
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .foregroundStyle(AACTheme.cardLabel)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, AACTheme.outerPadding)
                .padding(.top, AACTheme.outerPadding)
                .accessibilityLabel(phrase.isEmpty ? "No more choices" : "Current phrase: \(phrase)")

            actionCards(
                includeSpeak: !phrase.isEmpty,
                speakHint: "Speaks the words selected so far"
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
    }

    private func actionCards(includeSpeak: Bool, speakHint: String) -> some View {
        let cards = Group {
            if includeSpeak {
                AACCardButton(
                    title: "Speak",
                    emoji: "🔊",
                    fill: speakFill,
                    image: nil,
                    isEditMode: false,
                    action: { session.speakPhrase(using: app) },
                    onEdit: nil
                )
                .accessibilityHint(speakHint)
            }

            AACCardButton(
                title: "Back to home",
                emoji: "🏠",
                fill: homeFill,
                image: nil,
                isEditMode: false,
                action: { session.reset() },
                onEdit: nil
            )
            .accessibilityHint("Clears the message and returns to the home board")
        }

        return Group {
            if horizontalSizeClass == .compact {
                VStack(spacing: AACTheme.gridSpacing) { cards }
            } else {
                HStack(spacing: AACTheme.gridSpacing) { cards }
            }
        }
        .padding(AACTheme.outerPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
