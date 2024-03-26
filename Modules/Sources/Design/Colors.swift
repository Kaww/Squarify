import SwiftUI

public enum FramrColor: String, CaseIterable {
    case aquamarine
    case risdBlue
    case risdBlueLighter
    case sunglow
}

extension Color {
    public init(_ color: FramrColor) {
        self.init(color.rawValue, bundle: .module)
    }

    public static var aquamarine: Color { Color(FramrColor.aquamarine) }
    public static var risdBlue: Color { Color(FramrColor.risdBlue) }
    public static var risdBlueLighter: Color { Color(FramrColor.risdBlueLighter) }
    public static var sunglow: Color { Color(FramrColor.sunglow) }
}

extension ShapeStyle where Self == Color {
    public static var aquamarine: Color { Color.aquamarine }
    public static var risdBlue: Color { Color.risdBlue }
    public static var risdBlueLighter: Color { Color.risdBlueLighter }
    public static var sunglow: Color { Color.sunglow }
}
