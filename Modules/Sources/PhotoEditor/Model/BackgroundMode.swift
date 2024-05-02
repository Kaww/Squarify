import UIKit
import SwiftUI

enum BackgroundMode: CaseIterable, Hashable {
    case color
    case imageBlur


    var title: String {
        switch self {
        case .color:
            "_color_background_mode_label".localized

        case .imageBlur:
            "_blur_background_mode_label".localized
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

    static func blurEnlargedSize(photoSize: CGSize) -> CGSize {
        photoSize
            .zoomedToLargedSide()
            .enlargedBy(4 * blurAmountFor(photoSize: photoSize))
    }
}
