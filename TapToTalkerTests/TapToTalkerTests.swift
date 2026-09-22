import Testing
import CoreGraphics
@testable import TapToTalker

@MainActor
struct TapToTalkerTests {
    @Test func simpleModeLimitsHomeChoices() {
        let session = CommunicationSession()
        let options = session.visibleOptions(mode: .simple)
        #expect(options.count == 5)
        #expect(options.map(\.id) == ["want", "feel", "need", "person", "answer"])
    }

    @Test func guidedModeLimitsEachScreen() {
        let session = CommunicationSession()
        let home = session.visibleOptions(mode: .guided)
        #expect(home.count == 6)
    }

    @Test func advancedMaxStepsIsFour() {
        #expect(VocabularyMode.advanced.maxSteps == 4)
        #expect(VocabularyMode.simple.maxSteps == 3)
    }

    @Test func phraseBuildsFromPath() {
        let app = AppModel()
        let session = CommunicationSession()
        let want = DefaultVocabulary.root.options.first { $0.id == "want" }!
        session.select(want, app: app)
        #expect(session.phraseText(using: app) == "I want to")
        #expect(session.pathIDs == ["want"])
    }

    @Test func advancedDetailRequiresAdvancedMode() {
        let chicken = DefaultVocabulary.root.options
            .first { $0.id == "want" }!
            .options.first { $0.id == "eat" }!
            .options.first { $0.id == "chicken" }!

        let intermediate = chicken.filtered(for: .intermediate)
        #expect(intermediate.options.isEmpty)

        let advanced = chicken.filtered(for: .advanced)
        #expect(advanced.options.map(\.id) == ["nuggets", "strips", "warm", "cold"])
    }

    @Test func boardLayoutFiveCardsUsesModestSpacingAndLargeTiles() {
        let size = CGSize(width: 1100, height: 700)
        let plan = BoardLayout.plan(
            cardCount: 5,
            in: size,
            maxColumns: BoardLayout.maxColumns(for: .simple, cardCount: 5)
        )
        #expect(plan.spacing <= BoardLayout.maxSpacing)
        #expect(plan.cardWidth >= 160)
        #expect(plan.cardHeight >= 160)
        // Cards should consume most of the shorter axis (prefer larger tiles over gutters).
        let usedHeight = CGFloat(plan.rows) * plan.cardHeight + CGFloat(plan.rows - 1) * plan.spacing
        #expect(usedHeight / size.height >= 0.55)
    }

    @Test func boardLayoutEightCardsPrefersFilledMultiRow() {
        let size = CGSize(width: 1100, height: 700)
        let plan = BoardLayout.plan(
            cardCount: 8,
            in: size,
            maxColumns: BoardLayout.maxColumns(for: .intermediate, cardCount: 8)
        )
        let cards = (0..<8).map { AACCard(id: "c\($0)", label: "X", emoji: "🔹") }
        let rows = BoardLayout.rows(from: cards, columns: plan.columns)
        #expect(rows.count == plan.rows)
        #expect(rows.flatMap(\.self).count == 8)
        // 8 packs cleanly (e.g. 4×2) — prefer multi-row over a single stretched row.
        #expect(plan.rows >= 2)
        #expect(plan.columns <= 6)
        #expect(plan.spacing <= BoardLayout.maxSpacing)
        let usedHeight = CGFloat(plan.rows) * plan.cardHeight + CGFloat(plan.rows - 1) * plan.spacing
        #expect(usedHeight / size.height >= 0.55)
    }

    @Test func boardLayoutSevenCardsLeavesIncompleteLastRow() {
        let size = CGSize(width: 1100, height: 700)
        let plan = BoardLayout.plan(
            cardCount: 7,
            in: size,
            maxColumns: BoardLayout.maxColumns(for: .intermediate, cardCount: 7)
        )
        let cards = (0..<7).map { AACCard(id: "c\($0)", label: "X", emoji: "🔹") }
        let rows = BoardLayout.rows(from: cards, columns: plan.columns)
        #expect(rows.count == plan.rows)
        #expect(rows.last?.count ?? 0 < plan.columns)
        #expect(plan.spacing <= BoardLayout.maxSpacing)
    }
}
