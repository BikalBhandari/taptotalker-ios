import AVFoundation
import Foundation

@MainActor
final class SpeechService {
    static let shared = SpeechService()

    /// Lazy: AVSpeechSynthesizer() boots the TTS subsystem and can block the main
    /// thread for seconds, so don't create it until the first speak request.
    private lazy var synthesizer = AVSpeechSynthesizer()

    private init() {}

    func speak(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
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

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
