import SwiftUI

public enum BorderMode: String, CaseIterable, Identifiable  {
    case fixed
    case proportional

    public var id: Self { self }

    var title: String {
        switch self {
        case .fixed:
            return "Fixed"

        case .proportional:
            return "Proportional"
        }
    }

    var icon: Image {
        switch self {
        case .fixed:
            return Image(systemName: "equal")

        case .proportional:
            return Image(systemName: "percent")
        }
    }

    var unit: String {
        switch self {
        case .fixed:
            return "px"

        case .proportional:
            return "%"
        }
    }
}
