import Testing
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

    @Test func advancedChickenDetails() {
        let chicken = DefaultVocabulary.root.options
            .first { $0.id == "want" }!
            .options.first { $0.id == "eat" }!
            .options.first { $0.id == "chicken" }!

        let intermediate = chicken.filtered(for: .intermediate)
        #expect(intermediate.options.isEmpty)

        let advanced = chicken.filtered(for: .advanced)
        #expect(advanced.options.map(\.id) == ["nuggets", "strips", "chicken-sandwich", "wings"])
    }

    @Test func wantIncludesSleepAndPlay() {
        let want = DefaultVocabulary.root.options.first { $0.id == "want" }!
        #expect(want.options.map(\.id).contains("sleep"))
        #expect(want.options.map(\.id).contains("play"))
        #expect(!want.options.map(\.id).contains("rest"))
    }

    @Test func personIncludesFamilyMembers() {
        let person = DefaultVocabulary.root.options.first { $0.id == "person" }!
        #expect(person.options.count <= VocabularyMode.maxTilesPerScreen)
        #expect(
            person.options.prefix(6).map(\.id) == [
                "mom", "dad", "brother", "sister", "grandma", "grandpa"
            ]
        )
    }

    @Test func noBoardExceedsNineTiles() {
        func assertLimit(_ card: AACCard) {
            #expect(card.options.count <= VocabularyMode.maxTilesPerScreen)
            for child in card.options {
                assertLimit(child)
            }
        }
        #expect(DefaultVocabulary.root.options.count <= VocabularyMode.maxTilesPerScreen)
        for card in DefaultVocabulary.root.options {
            assertLimit(card)
        }
    }

    @Test func notOkayHurtHasAdvancedDetails() {
        let hurt = DefaultVocabulary.root.options
            .first { $0.id == "not-okay" }!
            .options.first { $0.id == "hurt" }!

        #expect(hurt.filtered(for: .intermediate).options.isEmpty)
        #expect(hurt.filtered(for: .advanced).options.map(\.id) == ["head", "tummy", "other"])
    }

    @Test func guidedPeopleShowsFamilyFirst() {
        let app = AppModel()
        let session = CommunicationSession()
        let person = DefaultVocabulary.root.options.first { $0.id == "person" }!
        session.select(person, app: app)
        let visible = session.visibleOptions(mode: .guided)
        #expect(visible.map(\.id) == ["mom", "dad", "brother", "sister", "grandma", "grandpa"])
    }
}
