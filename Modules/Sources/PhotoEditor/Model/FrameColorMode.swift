import UIKit
import SwiftUI

enum FrameColorMode: CaseIterable, Hashable {
  case color
  case imageBlur

  var title: String {
    switch self {
    case .color:
      "_color_frame_mode_label".localized

    case .imageBlur:
      "_blur_frame_mode_label".localized
    }
  }

  var icon: Image {
    switch self {
    case .color:
      Image(systemName: "paintbrush.pointed.fill")

    case .imageBlur:
      Image(systemName: "wand.and.stars")
    }
  }

  static func blurAmountFor(photoSize: CGSize) -> CGFloat {
    photoSize.smallestSide / 7.5
  }

  static func scale(imageSize: CGSize, frameSize: CGSize) -> CGSize {
    let widthRatio = frameSize.width / imageSize.width
    let heightRatio = frameSize.height / imageSize.height
    let scale = max(widthRatio, heightRatio)

    let newWidth = imageSize.width * scale
    let newHeight = imageSize.height * scale

    return CGSize(width: newWidth, height: newHeight)
      .enlargedBy(4 * blurAmountFor(photoSize: frameSize))
  }

  static var defaultColor: Color { .white }
}
