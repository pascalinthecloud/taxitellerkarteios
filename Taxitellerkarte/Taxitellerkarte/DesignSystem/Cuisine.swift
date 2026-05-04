import SwiftUI

nonisolated enum Cuisine: Hashable, Sendable {
    case greek
    case turkish
    case german
    case imbiss
    case fastFood
    case other(String)

    init(raw: String?) {
        switch raw?.lowercased() {
        case "greek", "griechisch":            self = .greek
        case "turkish", "türkisch", "doener",
             "döner", "kebab":                 self = .turkish
        case "german", "deutsch":              self = .german
        case "imbiss", "snack":                self = .imbiss
        case "fast_food", "fastfood",
             "fast-food":                      self = .fastFood
        case let other?:                       self = .other(other)
        case nil:                              self = .imbiss
        }
    }

    var label: String {
        switch self {
        case .greek:        "Griechisch"
        case .turkish:      "Türkisch"
        case .german:       "Deutsch"
        case .imbiss:       "Imbiss"
        case .fastFood:     "Fast Food"
        case .other(let s): s.capitalized
        }
    }

    var symbol: String {
        switch self {
        case .greek:        "leaf.fill"
        case .turkish:      "flame.fill"
        case .german:       "fork.knife"
        case .imbiss:       "takeoutbag.and.cup.and.straw.fill"
        case .fastFood:     "fork.knife.circle.fill"
        case .other:        "fork.knife"
        }
    }
}
