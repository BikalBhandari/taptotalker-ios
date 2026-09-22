import SwiftUI
import UIKit

struct AACCardButton: View {
    let title: String
    let emoji: String
    let image: UIImage?
    let isEditMode: Bool
    let action: () -> Void
    let onEdit: (() -> Void)?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var emojiSize: CGFloat = 56

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                visual
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 72 : 88)

                Text(title)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(.primary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: AACTheme.minCardHeight)
            .background(AACTheme.cardBackground, in: RoundedRectangle(cornerRadius: AACTheme.cardCorner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AACTheme.cardCorner, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: AACTheme.cardCorner, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isEditMode ? "Double tap to select. Use the Edit action to customize." : "Adds this word to your message and speaks it.")
        .accessibilityAction(named: "Edit card") {
            onEdit?()
        }
        .overlay(alignment: .topTrailing) {
            if isEditMode, let onEdit {
                Button("Edit", systemImage: "pencil.circle.fill", action: onEdit)
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .foregroundStyle(.tint)
                    .padding(8)
                    .accessibilityLabel("Edit \(title)")
            }
        }
    }

    @ViewBuilder
    private var visual: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: emojiSize + 16, height: emojiSize + 16)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .accessibilityHidden(true)
        } else {
            Text(emoji)
                .font(.system(size: emojiSize))
                .accessibilityHidden(true)
        }
    }
}
