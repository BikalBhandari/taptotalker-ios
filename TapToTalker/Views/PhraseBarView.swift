import SwiftUI

struct PhraseBarView: View {
    let phrase: String
    let stepLabel: String
    let prompt: String
    let isComplete: Bool
    let canUndo: Bool
    let onSpeak: () -> Void
    let onClear: () -> Void
    let onUndo: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(stepLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 8)

                Button("Undo", systemImage: "arrow.uturn.backward", action: onUndo)
                    .disabled(!canUndo)
                    .frame(minWidth: AACTheme.minTouch, minHeight: AACTheme.minTouch)

                Button("Clear", systemImage: "xmark.circle", action: onClear)
                    .disabled(phrase.isEmpty)
                    .frame(minWidth: AACTheme.minTouch, minHeight: AACTheme.minTouch)
            }

            Text(isComplete ? "Use this phrase" : prompt)
                .font(.title.weight(.bold))
                .accessibilityAddTraits(.isHeader)

            Text(phrase.isEmpty ? "Select one" : phrase)
                .font(.title2)
                .foregroundStyle(phrase.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .accessibilityLabel(phrase.isEmpty ? "No words selected yet" : "Current phrase: \(phrase)")

            Button(action: onSpeak) {
                Label("Speak", systemImage: "speaker.wave.2.fill")
                    .font(.title2.weight(.bold))
                    .frame(maxWidth: .infinity, minHeight: 56)
            }
            .buttonStyle(.borderedProminent)
            .disabled(phrase.isEmpty)
            .accessibilityHint("Speaks the full phrase out loud")
        }
        .padding(AACTheme.outerPadding)
        .background(.regularMaterial)
    }
}
