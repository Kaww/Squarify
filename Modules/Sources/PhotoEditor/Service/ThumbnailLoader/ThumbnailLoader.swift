import UIKit

public protocol ThumbnailLoader {
    func loadThumbnail(ofSize size: CGSize, for image: UIImage) async -> UIImage?
}
