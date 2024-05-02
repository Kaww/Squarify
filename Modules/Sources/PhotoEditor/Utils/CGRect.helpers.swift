import Foundation

extension CGRect {
    func rounded() -> CGRect {
        .init(
            x: minX.rounded(),
            y: minY.rounded(),
            width: width.rounded(),
            height: height.rounded()
        )
    }
}
