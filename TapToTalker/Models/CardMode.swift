import Foundation

enum CardMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case `default`
    case custom
    case edit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .default: return "Default"
        case .custom: return "Custom"
        case .edit: return "Edit"
        }
    }

    var detail: String {
        switch self {
        case .default: return "Built-in labels and emoji"
        case .custom: return "Show caregiver-saved labels and images"
        case .edit: return "Edit cards and save them as custom"
        }
    }

    var usesCustomContent: Bool {
        self == .custom || self == .edit
    }
}
