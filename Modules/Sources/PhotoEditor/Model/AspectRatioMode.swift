import Foundation
import SwiftUI

extension CGSize {
  var isPortrait: Bool {
    height >= width
  }
}

enum AspectRatioMode: CaseIterable, Hashable, Identifiable {
  case square
  case instaPortrait
  case instaLandscape

  public var id: Self { self }

  var allCases: [Self] { [.instaPortrait, .square, .instaLandscape] }

  var ratio: CGFloat {
    switch self {
    case .square: Self.squareRatio
    case .instaPortrait: Self.instaPortraitRatio
    case .instaLandscape: Self.instaLandscapeRatio
    }
  }

  var isPortrait: Bool {
    switch self {
    case .square: true
    case .instaPortrait: true
    case .instaLandscape: false
    }
  }

  private static let squareRatio: CGFloat = 1
  private static let instaPortraitRatio: CGFloat = 4/5
  private static let instaLandscapeRatio: CGFloat = 1.91/1

  var title: String {
    switch self {
    case .square: "_aspect_ratio_title_square".localized
    case .instaPortrait: "_aspect_ratio_title_instaPortrait".localized
    case .instaLandscape: "_aspect_ratio_title_instaLandscape".localized
    }
  }

  var icon: Image {
    switch self {
    case .square: Image(systemName: "square")
    case .instaPortrait: Image(systemName: "rectangle.ratio.3.to.4")
    case .instaLandscape: Image(systemName: "rectangle.ratio.16.to.9")
    }
  }

  /// Returns vertical or horizontal padding depending on the touching side
  func previewPaddingInsets(
    forImageSize imageSize: CGSize,
    paddingAmount: CGFloat
  ) -> EdgeInsets {
    let side = imageSize.touchingSides(forFrameAspectRatio: self)
    switch side {
    case .vertical:
      return EdgeInsets(top: paddingAmount, leading: 0, bottom: paddingAmount, trailing: 0)
    case .horizontal:
      return EdgeInsets(top: 0, leading: paddingAmount, bottom: 0, trailing: paddingAmount)
    }
  }
}
