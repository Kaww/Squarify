import UIKit

struct MockThumbnailLoader: ThumbnailLoader {
    func loadThumbnail(ofSize size: CGSize, for image: UIImage) async -> UIImage? {
        return image
    }
}
