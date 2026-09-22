import AVFoundation
import Foundation

@MainActor
final class SpeechService {
    static let shared = SpeechService()

    /// Created lazily — `AVSpeechSynthesizer` init can be costly on first launch.
    private var synthesizer: AVSpeechSynthesizer?

    private init() {
        LaunchProbe.mark("SpeechService.init (no synthesizer yet)")
    }

    func speak(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let synth = resolvedSynthesizer()
        if synth.isSpeaking {
            synth.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.92
        utterance.pitchMultiplier = 1.05
        utterance.preUtteranceDelay = 0.02
        utterance.postUtteranceDelay = 0.05

        if let voice = AVSpeechSynthesisVoice(language: Locale.current.language.languageCode?.identifier ?? "en-US")
            ?? AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }

        synth.speak(utterance)
    }

    func stop() {
        synthesizer?.stopSpeaking(at: .immediate)
    }

    /// Optional warm-up after first frame so the first tap isn't the cold path.
    func prepareInBackground() {
        Task(priority: .utility) { @MainActor in
            _ = resolvedSynthesizer()
            LaunchProbe.mark("SpeechService.warmed")
        }
    }

    private func resolvedSynthesizer() -> AVSpeechSynthesizer {
        if let synthesizer { return synthesizer }
        LaunchProbe.mark("SpeechService creating AVSpeechSynthesizer")
        let created = AVSpeechSynthesizer()
        synthesizer = created
        return created
    }
}
