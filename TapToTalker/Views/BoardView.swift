import SwiftUI

struct BoardView: View {
    @Environment(AppModel.self) private var app
    @Bindable var session: CommunicationSession

    let onEditCard: (AACCard) -> Void

    private var mode: VocabularyMode { app.vocabularyMode }
    private var options: [AACCard] { session.visibleOptions(mode: mode) }
    private var complete: Bool { session.isComplete(mode: mode) }
    private var phrase: String { session.phraseText(using: app) }

    var body: some View {
        ZStack {
            AACTheme.boardBackground
                .ignoresSafeArea()

            if complete {
                completedState
            } else if options.isEmpty {
                emptyFallback
            } else {
                cardGrid
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !session.pathIDs.isEmpty && !complete {
                minimalPhraseStrip
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(options.isEmpty ? "Communication board" : "Communication board, \(options.count) choices")
        .onAppear {
            LaunchProbe.mark("BoardView.onAppear (interactive board)")
            OrientationLock.lockLandscape()
        }
    }

    private var cardGrid: some View {
        GeometryReader { geo in
            let inset = AACTheme.outerPadding
            let available = CGSize(
                width: max(geo.size.width - inset * 2, BoardLayout.minCardSide),
                height: max(geo.size.height - inset * 2, BoardLayout.minCardSide)
            )
            let plan = BoardLayout.plan(
                cardCount: options.count,
                in: available,
                maxColumns: BoardLayout.maxColumns(for: mode, cardCount: options.count)
            )
            let rows = BoardLayout.rows(from: options, columns: plan.columns)

            VStack(spacing: plan.spacing) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: plan.spacing) {
                        ForEach(row) { card in
                            cardButton(for: card)
                                .frame(width: plan.cardWidth, height: plan.cardHeight)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(inset)
        }
    }

    private func cardButton(for card: AACCard) -> some View {
        AACCardButton(
            title: app.displayLabel(for: card),
            emoji: app.displayEmoji(for: card),
            tone: card.tone,
            image: app.cardMode.usesCustomContent ? app.image(for: card.id) : nil,
            isEditMode: app.cardMode == .edit,
            action: {
                session.select(card, app: app)
            },
            onEdit: app.cardMode == .edit ? { onEditCard(card) } : nil
        )
        .id("\(card.id)-\(app.overridesVersion)-\(app.cardMode.rawValue)")
    }

    /// Compact strip only while a phrase is in progress — keeps the board primary.
    private var minimalPhraseStrip: some View {
        HStack(spacing: 12) {
            Text(phrase)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("Current phrase: \(phrase)")

            Button("Undo", systemImage: "arrow.uturn.backward") {
                session.undoLast()
            }
            .labelStyle(.iconOnly)
            .frame(minWidth: AACTheme.minTouch, minHeight: AACTheme.minTouch)
            .accessibilityLabel("Undo last word")

            Button("Clear", systemImage: "xmark") {
                session.reset()
            }
            .labelStyle(.iconOnly)
            .frame(minWidth: AACTheme.minTouch, minHeight: AACTheme.minTouch)
            .accessibilityLabel("Clear phrase")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.regularMaterial)
    }

    private var completedState: some View {
        VStack(spacing: 24) {
            Text(phrase)
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .accessibilityAddTraits(.isHeader)

            Button {
                session.speakPhrase(using: app)
            } label: {
                Label("Speak", systemImage: "speaker.wave.2.fill")
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: 320, minHeight: 56)
            }
            .buttonStyle(.borderedProminent)

            Button("Start over") {
                session.reset()
            }
            .font(.title3.weight(.semibold))
            .frame(minHeight: AACTheme.minTouch)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AACTheme.sectionSpacing)
    }

    private var emptyFallback: some View {
        VStack(spacing: 16) {
            Text("No cards to show")
                .font(.title2.weight(.semibold))
            Button("Back to home") {
                session.reset()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
