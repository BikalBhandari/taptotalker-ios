import UIKit

/// Resolves bundled OpenMoji artwork for vocabulary emoji.
/// Assets live in `Assets.xcassets/OpenMoji` as `OpenMoji_<CODEPOINT>` imagesets.
enum OpenMoji {
    static let attribution = "Card symbols: OpenMoji (CC BY-SA 4.0) — openmoji.org"

    private static let cache = NSCache<NSString, UIImage>()

    static func image(forEmoji emoji: String) -> UIImage? {
        let trimmed = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let cacheKey = trimmed as NSString
        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }

        for candidate in assetNameCandidates(for: trimmed) {
            if let image = UIImage(named: candidate) {
                cache.setObject(image, forKey: cacheKey)
                return image
            }
        }
        return nil
    }

    /// Asset catalog names for an emoji string, trying FE0F variants OpenMoji uses.
    static func assetNameCandidates(for emoji: String) -> [String] {
        let hex = codepointsHex(emoji)
        var seen = Set<String>()
        var names: [String] = []

        for variant in hexVariants(hex) {
            let name = "OpenMoji_" + variant.replacingOccurrences(of: "-", with: "_")
            if seen.insert(name).inserted {
                names.append(name)
            }
        }
        return names
    }

    private static func codepointsHex(_ string: String) -> String {
        string.unicodeScalars.map { String($0.value, radix: 16).uppercased() }.joined(separator: "-")
    }

    private static func hexVariants(_ hex: String) -> [String] {
        let parts = hex.split(separator: "-").map(String.init)
        var variants: [String] = [hex]

        let stripped = parts.filter { $0 != "FE0F" }
        if stripped.count != parts.count {
            variants.append(stripped.joined(separator: "-"))
        }

        if parts.count == 1, parts[0] != "FE0F" {
            variants.append(parts[0] + "-FE0F")
        }

        return variants
    }
}
