import UIKit

enum BackgroundMode {
    case color(UIColor)
    case imageBlur

    var color: UIColor {
        switch self {
        case .color(let color):
            return color

        case .imageBlur:
            return .clear
        }
    }

    static func blurAmountFor(photoSize: CGSize) -> CGFloat {
        photoSize.smallestSide / 7.5
    }

    static func blurEnlargedSize(photoSize: CGSize) -> CGSize {
        photoSize
            .zoomedToLargedSide()
            .enlargedBy(4 * blurAmountFor(photoSize: photoSize))
    }
}
