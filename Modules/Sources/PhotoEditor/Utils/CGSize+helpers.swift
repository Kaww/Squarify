import Foundation

extension CGSize {

  enum TouchingSide {
    case vertical, horizontal
  }

  /// Touching side of an image withing a frame of `frameRatio` ratio.
  func touchingSides(forFrameAspectRatio frameRatio: AspectRatioMode) -> TouchingSide {
    let imageRatio = width / height
    let rf = frameRatio.ratio

    switch imageRatio {
    case let ri where ri < rf:
      return .vertical

    case let ri where ri > rf:
      return .horizontal

    default: // ri == rf
      if frameRatio.isPortrait {
        return .vertical
      } else {
        return .horizontal
      }
    }
  }

  /// Touching side SIZE of an image withing a frame of `frameRatio` ratio.
  func touchingSideSize(forFrameAspectRatio frameRatio: AspectRatioMode) -> CGFloat {
    switch touchingSides(forFrameAspectRatio: frameRatio) {
    case .vertical:
      return height

    case .horizontal:
      return width
    }
  }

  func centered(with rect: CGRect) -> CGRect {
    .init(
      x: (rect.width - width) / 2,
      y: (rect.height - height) / 2,
      width: width,
      height: height
    )
  }

  private var largestSide: CGFloat {
    width > height ? width : height
  }

  var smallestSide: CGFloat {
    width < height ? width : height
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

  var isPortrait: Bool {
    height >= width
  }

  var rounded: CGSize {
    CGSize(width: width.rounded(), height: height.rounded())
  }
}
