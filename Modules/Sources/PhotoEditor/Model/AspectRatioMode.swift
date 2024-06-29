import Foundation

enum AspectRatioMode: CaseIterable, Hashable {
    case auto
    case square
    case instaPortait
    case instaLandscape

    func valueFor(imageSize: CGSize) -> CGFloat {
        switch self {
        case .auto:
            if imageSize.height >= imageSize.width {
                return Self.instaPortraitRatio
            }
            return Self.instaLandscapeRatio

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
        case .auto:
            return "_aspect_ratio_title_auto"
        case .square:
            return "_aspect_ratio_title_square"
        case .instaPortait:
            return "_aspect_ratio_title_instaPortait"
        case .instaLandscape:
            return "_aspect_ratio_title_instaLandscape"
        }
    }
}
