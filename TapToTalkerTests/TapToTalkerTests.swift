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
}
