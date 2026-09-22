import Foundation
import Observation
import UIKit

@Observable
@MainActor
final class AppModel {
    var settings: AppSettings
    var overridesVersion: Int = 0
    private(set) var didBootstrap = false

    private let store: PersistenceStore

    init(store: PersistenceStore? = nil) {
        LaunchProbe.mark("AppModel.init begin")
        // Avoid touching PersistenceStore.shared disk path during `@State` construction.
        if let store {
            self.store = store
            self.settings = store.settings
        } else {
            self.store = PersistenceStore.shared
            self.settings = .default
        }
        LaunchProbe.mark("AppModel.init end")
    }

    /// Call after the first board frame. Reloads caregiver settings without blocking launch.
    func bootstrapAfterFirstFrame() {
        guard !didBootstrap else { return }
        didBootstrap = true
        LaunchProbe.mark("AppModel.bootstrap begin")
        let changed = store.loadFromDiskIfNeeded()
        settings = store.settings
        if changed {
            overridesVersion += 1
        }
        LaunchProbe.mark("AppModel.bootstrap end")
        SpeechService.shared.prepareInBackground()
    }

    var vocabularyMode: VocabularyMode {
        get { settings.vocabularyMode }
        set {
            settings.vocabularyMode = newValue
            persistSettings()
        }
    }

    var cardMode: CardMode {
        get { settings.cardMode }
        set {
            settings.cardMode = newValue
            persistSettings()
        }
    }

    var hasPIN: Bool { settings.hasPIN }

    func validatePIN(_ attempt: String) -> Bool {
        settings.caregiverPIN == attempt
    }

    func saveCaregiverPIN(_ pin: String) {
        settings.caregiverPIN = pin.trimmingCharacters(in: .whitespacesAndNewlines)
        persistSettings()
    }

    func clearPIN() {
        settings.caregiverPIN = ""
        persistSettings()
    }

    func displayLabel(for card: AACCard) -> String {
        store.displayLabel(for: card, cardMode: settings.cardMode)
    }

    func displayEmoji(for card: AACCard) -> String {
        store.displayEmoji(for: card, cardMode: settings.cardMode)
    }

    func image(for cardID: String) -> UIImage? {
        // Default mode never needs custom images on the hot path.
        guard settings.cardMode.usesCustomContent else { return nil }
        return store.image(for: cardID)
    }

    func saveCardOverride(cardID: String, label: String?, emoji: String?, imageData: Data?) {
        store.saveOverride(cardID: cardID, label: label, emoji: emoji, imageData: imageData)
        overridesVersion += 1
    }

    func clearCardOverride(cardID: String) {
        store.clearOverride(cardID: cardID)
        overridesVersion += 1
    }

    func override(for cardID: String) -> CustomCardOverride? {
        store.override(for: cardID)
    }

    private func persistSettings() {
        store.updateSettings { $0 = settings }
        settings = store.settings
    }
}
