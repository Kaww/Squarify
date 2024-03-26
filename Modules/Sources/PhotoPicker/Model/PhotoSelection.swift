import UIKit

public struct PhotoSelection: Identifiable {
    public let photos: [UIImage]
    public let id: String

    public init(photos: [UIImage], id: String) {
        self.photos = photos
        self.id = id
    }
}
