import SwiftUI

public enum SquarifyColor: String, CaseIterable {
    case aquamarine
    case risdBlue
    case risdBlueLighter
    case sunglow
    case pinkLove

    case neutral0
    case neutral8
    case neutral25
    case neutral56
    case neutral100
    case neutral100Constant
}

extension Color {
    public init(_ color: SquarifyColor) {
        self.init(color.rawValue, bundle: .module)
    }

    public static var aquamarine: Color { .init(SquarifyColor.aquamarine) }
    public static var risdBlue: Color { .init(SquarifyColor.risdBlue) }
    public static var risdBlueLighter: Color { .init(SquarifyColor.risdBlueLighter) }
    public static var sunglow: Color { .init(SquarifyColor.sunglow) }
    public static var pinkLove: Color { .init(SquarifyColor.pinkLove) }

    public static var neutral0: Color { .init(SquarifyColor.neutral0) }
    public static var neutral8: Color { .init(SquarifyColor.neutral8) }
    public static var neutral25: Color { .init(SquarifyColor.neutral25) }
    public static var neutral56: Color { .init(SquarifyColor.neutral56) }
    public static var neutral100: Color { .init(SquarifyColor.neutral100) }
    public static var neutral100Constant: Color { .init(SquarifyColor.neutral100Constant) }
}

extension ShapeStyle where Self == Color {
    public static var aquamarine: Color { Color.aquamarine }
    public static var risdBlue: Color { Color.risdBlue }
    public static var risdBlueLighter: Color { Color.risdBlueLighter }
    public static var sunglow: Color { Color.sunglow }
    public static var pinkLove: Color { .init(SquarifyColor.pinkLove) }

    public static var neutral0: Color { .init(SquarifyColor.neutral0) }
    public static var neutral8: Color { .init(SquarifyColor.neutral8) }
    public static var neutral25: Color { .init(SquarifyColor.neutral25) }
    public static var neutral56: Color { .init(SquarifyColor.neutral56) }
    public static var neutral100: Color { .init(SquarifyColor.neutral100) }
    public static var neutral100Constant: Color { .init(SquarifyColor.neutral100Constant) }
}
