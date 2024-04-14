import SwiftUI

public enum SquarifyColor: String, CaseIterable {
    case aquamarine
    case risdBlue
    case risdBlueLighter
    case sunglow
}

extension Color {
    public init(_ color: SquarifyColor) {
        self.init(color.rawValue, bundle: .module)
    }

    public static var aquamarine: Color { Color(SquarifyColor.aquamarine) }
    public static var risdBlue: Color { Color(SquarifyColor.risdBlue) }
    public static var risdBlueLighter: Color { Color(SquarifyColor.risdBlueLighter) }
    public static var sunglow: Color { Color(SquarifyColor.sunglow) }
}

extension ShapeStyle where Self == Color {
    public static var aquamarine: Color { Color.aquamarine }
    public static var risdBlue: Color { Color.risdBlue }
    public static var risdBlueLighter: Color { Color.risdBlueLighter }
    public static var sunglow: Color { Color.sunglow }
}
