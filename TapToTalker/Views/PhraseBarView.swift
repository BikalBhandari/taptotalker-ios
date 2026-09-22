import SwiftUI

/// Speak + live phrase readout + clear while a message is being built.
/// The text box shows full selected labels — helpful when card text is short or truncated.
struct PhraseBarView: View {
    let phrase: String
    let canClear: Bool
    let onClear: () -> Void
    let onSpeak: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onSpeak) {
                Label("Speak", systemImage: "speaker.wave.2.fill")
                    .font(.title3.weight(.bold))
                    .labelStyle(.iconOnly)
                    .frame(width: 56, height: 56)
            }
            .buttonStyle(.borderedProminent)
            .disabled(phrase.isEmpty)
            .accessibilityLabel("Speak phrase")
            .accessibilityHint("Speaks the words selected so far")

            phraseBox

            Button("Clear", systemImage: "xmark.circle", action: onClear)
                .font(.title3.weight(.bold))
                .disabled(!canClear)
                .frame(minWidth: AACTheme.minTouch, minHeight: 56)
        }
        .padding(.horizontal, AACTheme.outerPadding)
        .padding(.vertical, 10)
        .background(AACTheme.boardBackground)
        .accessibilityElement(children: .contain)
    }

    private var phraseBox: some View {
        Text(phrase.isEmpty ? "Your message…" : phrase)
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundStyle(phrase.isEmpty ? AACTheme.cardLabel.opacity(0.45) : AACTheme.cardLabel)
            .lineLimit(2)
            .minimumScaleFactor(0.55)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.95))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(AACTheme.cardLabel.opacity(0.12), lineWidth: 1)
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(phrase.isEmpty ? "No words selected yet" : "Current phrase: \(phrase)")
            .accessibilityAddTraits(.updatesFrequently)
    }
}
