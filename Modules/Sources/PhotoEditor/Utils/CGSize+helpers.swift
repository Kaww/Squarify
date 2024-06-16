import Foundation

extension CGSize {
    var largestSide: CGFloat {
        width > height ? width : height
    }

    var smallestSide: CGFloat {
        width < height ? width : height
    }

    func centered(with rect: CGRect) -> CGRect {
        .init(
            x: (rect.width - width) / 2,
            y: (rect.height - height) / 2,
            width: width,
            height: height
        )
    }

    func zoomedToLargedSide() -> CGSize {
        let ratio = largestSide / smallestSide
        return .init(
            width: width * ratio,
            height: height * ratio
        )
    }

    func enlargedBy(_ value: CGFloat) -> CGSize {
        .init(width: width + value, height: height + value)
    }
}
