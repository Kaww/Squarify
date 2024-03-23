import UIKit

public struct DefaultThumbnailLoader: ThumbnailLoader {

    public init() {}

    public func loadThumbnail(ofSize size: CGSize, for image: UIImage) async -> UIImage? {
        return await image.byPreparingThumbnail(ofSize: size)
    }
}
