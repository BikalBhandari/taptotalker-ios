import SwiftUI

struct BoardView: View {
    @Environment(AppModel.self) private var app
    @Bindable var session: CommunicationSession

    let onEditCard: (AACCard) -> Void

    private var mode: VocabularyMode { app.vocabularyMode }
    private var options: [AACCard] { session.visibleOptions(mode: mode) }
    private var complete: Bool { session.isComplete(mode: mode) }
    private var phrase: String { session.phraseText(using: app) }

    private var columns: [GridItem] {
        // Prefer a wide landscape board: more columns when space allows.
        let count: Int
        switch mode {
        case .simple:
            count = min(max(options.count, 1), 5)
        case .guided:
            count = min(max(options.count, 1), 3)
        case .intermediate, .advanced:
            count = min(max(options.count, 1), options.count <= 4 ? options.count : 4)
        }
        return Array(repeating: GridItem(.flexible(), spacing: AACTheme.gridSpacing), count: max(count, 1))
    }

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
            OrientationLock.lockLandscape()
        }
    }

    private var cardGrid: some View {
        GeometryReader { geo in
            let landscape = geo.size.width > geo.size.height
            let columnCount: Int = {
                switch mode {
                case .simple:
                    return landscape ? min(options.count, 5) : min(options.count, 3)
                case .guided:
                    return min(options.count, 3)
                case .intermediate, .advanced:
                    if landscape {
                        return min(max(options.count, 1), options.count <= 6 ? options.count : 4)
                    }
                    return min(max(options.count, 1), 2)
                }
            }()
            let gridColumns = Array(
                repeating: GridItem(.flexible(), spacing: AACTheme.gridSpacing),
                count: max(columnCount, 1)
            )
            let rows = max(1, Int(ceil(Double(options.count) / Double(max(columnCount, 1)))))
            let availableHeight = max(geo.size.height - 32, AACTheme.minCardHeight)
            let rowHeight = max(
                AACTheme.minCardHeight,
                (availableHeight - CGFloat(rows - 1) * AACTheme.gridSpacing) / CGFloat(rows)
            )

            LazyVGrid(columns: gridColumns, spacing: AACTheme.gridSpacing) {
                ForEach(options) { card in
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
                    .frame(minHeight: rowHeight)
                    .id("\(card.id)-\(app.overridesVersion)-\(app.cardMode.rawValue)")
                }
            }
            .padding(AACTheme.outerPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
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
        // Should rarely appear; never show a blank white screen.
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
