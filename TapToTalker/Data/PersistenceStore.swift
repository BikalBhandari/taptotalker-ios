import Foundation
import UIKit

struct AppSettings: Codable, Equatable, Sendable {
    var vocabularyMode: VocabularyMode
    var cardMode: CardMode
    /// Plain local PIN string; empty means no PIN protection.
    var caregiverPIN: String

    static let `default` = AppSettings(
        vocabularyMode: .intermediate,
        cardMode: .default,
        caregiverPIN: ""
    )

    var hasPIN: Bool { !caregiverPIN.isEmpty }
}

@MainActor
final class PersistenceStore {
    static let shared = PersistenceStore()

    private let settingsURL: URL
    private let overridesURL: URL
    private let imagesDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private(set) var settings: AppSettings
    private(set) var overrides: [String: CustomCardOverride]
    private var didLoadFromDisk = false
    private var imageCache: [String: UIImage] = [:]

    private init() {
        LaunchProbe.mark("PersistenceStore.init begin")
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        settingsURL = docs.appendingPathComponent("settings.json")
        overridesURL = docs.appendingPathComponent("custom-cards.json")
        imagesDirectory = docs.appendingPathComponent("CustomCardImages", isDirectory: true)

        // Paint first frame with defaults — disk I/O happens in `loadFromDiskIfNeeded()`.
        settings = .default
        overrides = [:]
        LaunchProbe.mark("PersistenceStore.init end (defaults only)")
    }

    /// Loads settings/custom cards after the first frame. Safe to call repeatedly.
    @discardableResult
    func loadFromDiskIfNeeded() -> Bool {
        guard !didLoadFromDisk else { return false }
        didLoadFromDisk = true
        LaunchProbe.mark("PersistenceStore disk load begin")

        try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        settings = Self.load(AppSettings.self, from: settingsURL, decoder: decoder) ?? .default
        overrides = Self.load([String: CustomCardOverride].self, from: overridesURL, decoder: decoder) ?? [:]

        LaunchProbe.mark("PersistenceStore disk load end")
        return true
    }

    func updateSettings(_ update: (inout AppSettings) -> Void) {
        loadFromDiskIfNeeded()
        update(&settings)
        save(settings, to: settingsURL)
    }

    func override(for cardID: String) -> CustomCardOverride? {
        loadFromDiskIfNeeded()
        return overrides[cardID]
    }

    func saveOverride(cardID: String, label: String?, emoji: String?, imageData: Data?) {
        loadFromDiskIfNeeded()
        var entry = overrides[cardID] ?? CustomCardOverride()
        if let label {
            let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
            entry.label = trimmed.isEmpty ? nil : trimmed
        }
        if let emoji {
            let trimmed = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
            entry.emoji = trimmed.isEmpty ? nil : trimmed
        }
        if let imageData {
            let fileName = "\(cardID).jpg"
            let url = imagesDirectory.appendingPathComponent(fileName)
            try? imageData.write(to: url, options: .atomic)
            entry.imageFileName = fileName
            imageCache[cardID] = UIImage(data: imageData)
        }
        overrides[cardID] = entry
        save(overrides, to: overridesURL)
    }

    func clearOverride(cardID: String) {
        loadFromDiskIfNeeded()
        if let fileName = overrides[cardID]?.imageFileName {
            let url = imagesDirectory.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: url)
        }
        overrides.removeValue(forKey: cardID)
        imageCache.removeValue(forKey: cardID)
        save(overrides, to: overridesURL)
    }

    func image(for cardID: String) -> UIImage? {
        if let cached = imageCache[cardID] { return cached }
        loadFromDiskIfNeeded()
        guard let fileName = overrides[cardID]?.imageFileName else { return nil }
        let url = imagesDirectory.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return nil }
        imageCache[cardID] = image
        return image
    }

    func displayLabel(for card: AACCard, cardMode: CardMode) -> String {
        if cardMode.usesCustomContent, let custom = overrides[card.id]?.label, !custom.isEmpty {
            return custom
        }
        return card.label
    }

    func displayEmoji(for card: AACCard, cardMode: CardMode) -> String {
        if cardMode.usesCustomContent, let custom = overrides[card.id]?.emoji, !custom.isEmpty {
            return custom
        }
        return card.emoji
    }

    private func save<T: Encodable>(_ value: T, to url: URL) {
        do {
            let data = try encoder.encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            #if DEBUG
            print("Persistence save failed: \(error)")
            #endif
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, from url: URL, decoder: JSONDecoder) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(type, from: data)
    }
}
