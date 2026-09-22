import SwiftUI
import UIKit

struct AACCardButton: View {
    let title: String
    let emoji: String
    let fill: Color
    let image: UIImage?
    let isEditMode: Bool
    let action: () -> Void
    let onEdit: (() -> Void)?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: action) {
            // Color.clear expands with the grid cell; GeometryReader in an overlay
            // then measures the real tile size (GeometryReader as Button label collapses).
            Color.clear
                .overlay {
                    GeometryReader { geo in
                        let metrics = ContentMetrics(size: geo.size, dynamicTypeSize: dynamicTypeSize)

                        VStack(spacing: metrics.spacing) {
                            visual(size: metrics.emojiSize)

                            Text(title)
                                .font(.system(size: metrics.labelSize, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .lineLimit(metrics.lineLimit)
                                .minimumScaleFactor(0.75)
                                .foregroundStyle(AACTheme.cardLabel)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(metrics.padding)
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    }
                }
                .background(fill, in: RoundedRectangle(cornerRadius: AACTheme.cardCorner, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AACTheme.cardCorner, style: .continuous)
                        .strokeBorder(AACTheme.cardLabel.opacity(0.10), lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: AACTheme.cardCorner, style: .continuous))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Soft floor only — never force large mins that overflow smaller iPads.
        .frame(minHeight: AACTheme.minCardHeightFloor)
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
                    .font(.title)
                    .foregroundStyle(.tint)
                    .padding(12)
                    .accessibilityLabel("Edit \(title)")
            }
        }
    }

    @ViewBuilder
    private func visual(size: CGFloat) -> some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.18, style: .continuous))
                .accessibilityHidden(true)
        } else if let openMoji = OpenMoji.image(forEmoji: emoji) {
            Image(uiImage: openMoji)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.92, height: size * 0.92)
                .frame(width: size, height: size)
                .accessibilityHidden(true)
        } else {
            Text(emoji)
                .font(.system(size: size * 0.88))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .frame(width: size, height: size)
                .accessibilityHidden(true)
        }
    }
}

/// Sizes emoji + label from the laid-out card frame.
private struct ContentMetrics {
    let emojiSize: CGFloat
    let labelSize: CGFloat
    let spacing: CGFloat
    let padding: CGFloat
    let lineLimit: Int

    init(size: CGSize, dynamicTypeSize: DynamicTypeSize) {
        let shortest = max(min(size.width, size.height), 1)
        let a11yBump: CGFloat = dynamicTypeSize.isAccessibilitySize ? 1.12 : 1.0

        padding = max(12, shortest * 0.04)
        spacing = max(8, shortest * 0.03)
        lineLimit = dynamicTypeSize.isAccessibilitySize ? 3 : 2

        // Dominant AAC type — roughly a quarter to a third of the tile’s short edge.
        labelSize = min(max(48, shortest * 0.28), dynamicTypeSize.isAccessibilitySize ? 84 : 76) * a11yBump

        let labelBlock = labelSize * (lineLimit == 2 ? 1.15 : 1.8)
        let usableWidth = max(size.width - padding * 2, 1)
        let usableHeight = max(size.height - padding * 2 - spacing - labelBlock, 1)
        emojiSize = min(usableWidth * 0.86, usableHeight * 0.86) * a11yBump
    }
}
