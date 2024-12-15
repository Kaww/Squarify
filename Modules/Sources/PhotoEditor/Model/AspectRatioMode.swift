import Foundation
import SwiftUI

enum AspectRatioMode: CaseIterable, Hashable, Identifiable {
  case square
  case instaPortait
  case instaLandscape

  public var id: Self { self }

  var ratio: CGFloat {
    switch self {
    case .square:
      return Self.squareRatio

    case .instaPortait:
      return Self.instaPortraitRatio

    case .instaLandscape:
      return Self.instaPortraitRatio
    }
  }

  private static let squareRatio: CGFloat = 1
  private static let instaPortraitRatio: CGFloat = 4/5
  private static let instaLandscapeRatio: CGFloat = 1.91/1

  var title: String {
    switch self {
    case .square:
      return "_aspect_ratio_title_square".localized
    case .instaPortait:
      return "_aspect_ratio_title_instaPortait".localized
    case .instaLandscape:
      return "_aspect_ratio_title_instaLandscape".localized
    }
  }

  var icon: Image {
    switch self {
    case .square:
      Image(systemName: "square")

    case .instaPortait:
      Image(systemName: "rectangle.ratio.3.to.4")

    case .instaLandscape:
      Image(systemName: "rectangle.ratio.16.to.9")
    }
  }
}
