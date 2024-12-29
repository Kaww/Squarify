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

  /// Touching side of frame for a given inside image size.
  func touchingSides(insideImageSize imageSize: CGSize) -> TouchingSide {
    let frameRatio = width / height
    let ri = imageSize.width / imageSize.height

    switch frameRatio {
    case let rf where ri < rf:
      return .vertical

    case let rf where ri > rf:
      return .horizontal

    default: // ri == rf
      if frameRatio < 1 {
        // frame is portrait
        return .vertical
      } else {
        // frame is landscape
        return .horizontal
      }
    }
  }

  /// Touching side SIZE of frame for a given inside image size.
  func touchingSideSize(insideImageSize imageSize: CGSize) -> CGFloat {
    switch touchingSides(insideImageSize: imageSize) {
    case .vertical:
      return height

    case .horizontal:
      return width
    }
  }

  @available(*, deprecated, renamed: "touchingSideSize", message: "Use touchingSideSize(forFrameAspectRatio:)")
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
