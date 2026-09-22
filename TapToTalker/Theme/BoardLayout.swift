import CoreGraphics
import Foundation

/// Picks columns/rows and a fixed card size so boards with few cards grow
/// larger instead of stretching gutters across the screen.
struct BoardLayoutPlan: Equatable {
    let columns: Int
    let rows: Int
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let spacing: CGFloat

    var cardSize: CGSize { CGSize(width: cardWidth, height: cardHeight) }
}

enum BoardLayout {
    static let minSpacing: CGFloat = 12
    static let maxSpacing: CGFloat = 20
    static let minCardSide: CGFloat = 120
    /// Prefer roughly square / slightly tall AAC tiles.
    static let idealAspect: CGFloat = 0.92 // width / height

    static func plan(
        cardCount: Int,
        in available: CGSize,
        maxColumns: Int? = nil
    ) -> BoardLayoutPlan {
        let count = max(cardCount, 1)
        let width = max(available.width, minCardSide)
        let height = max(available.height, minCardSide)
        let columnCap = max(1, min(count, maxColumns ?? count))

        var best: BoardLayoutPlan?
        var bestScore: CGFloat = -.greatestFiniteMagnitude

        for columns in 1...columnCap {
            let rows = Int(ceil(Double(count) / Double(columns)))
            // Skip absurdly tall stacks when a wider option exists.
            if rows > columns + 2 && columnCap > columns { continue }

            let spacing = spacing(
                forColumns: columns,
                rows: rows,
                in: CGSize(width: width, height: height)
            )

            let cardWidth = (width - CGFloat(columns - 1) * spacing) / CGFloat(columns)
            let cardHeight = (height - CGFloat(rows - 1) * spacing) / CGFloat(rows)

            guard cardWidth >= minCardSide * 0.85, cardHeight >= minCardSide * 0.85 else {
                continue
            }

            // Prefer larger cards; lightly prefer near-ideal aspect; prefer fuller last rows.
            let area = cardWidth * cardHeight
            let aspect = cardWidth / max(cardHeight, 1)
            let aspectPenalty = abs(log(aspect / idealAspect)) * area * 0.18
            let lastRowCount = count - (rows - 1) * columns
            let fillBonus = CGFloat(lastRowCount) / CGFloat(columns) * area * 0.05
            // Prefer fewer rows when cards stay large (better for landscape AAC).
            let rowBonus = area * 0.02 / CGFloat(rows)

            let score = area - aspectPenalty + fillBonus + rowBonus
            if score > bestScore {
                bestScore = score
                best = BoardLayoutPlan(
                    columns: columns,
                    rows: rows,
                    cardWidth: cardWidth.rounded(.down),
                    cardHeight: cardHeight.rounded(.down),
                    spacing: spacing
                )
            }
        }

        if let best { return best }

        // Fallback: single row (or column) that still respects min size as much as possible.
        let columns = min(count, columnCap)
        let rows = Int(ceil(Double(count) / Double(columns)))
        let spacing = minSpacing
        return BoardLayoutPlan(
            columns: columns,
            rows: rows,
            cardWidth: max(minCardSide, (width - CGFloat(columns - 1) * spacing) / CGFloat(columns)),
            cardHeight: max(minCardSide, (height - CGFloat(rows - 1) * spacing) / CGFloat(rows)),
            spacing: spacing
        )
    }

    /// Cap gutters so leftover space grows the cards instead.
    private static func spacing(forColumns columns: Int, rows: Int, in size: CGSize) -> CGFloat {
        let hBudget = size.width / CGFloat(max(columns * 8, 1))
        let vBudget = size.height / CGFloat(max(rows * 8, 1))
        return min(maxSpacing, max(minSpacing, min(hBudget, vBudget)))
    }

    static func maxColumns(for mode: VocabularyMode, cardCount: Int) -> Int {
        switch mode {
        case .simple:
            return min(cardCount, 5)
        case .guided:
            return min(cardCount, 3)
        case .intermediate, .advanced:
            return min(cardCount, 6)
        }
    }

    static func rows(from cards: [AACCard], columns: Int) -> [[AACCard]] {
        guard columns > 0 else { return [cards] }
        var result: [[AACCard]] = []
        var index = 0
        while index < cards.count {
            let end = min(index + columns, cards.count)
            result.append(Array(cards[index..<end]))
            index = end
        }
        return result
    }
}
