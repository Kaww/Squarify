import UIKit

struct EditingImage {
    let image: UIImage
    let thumbnail: UIImage

    var sizeDescription: String {
        "\(Int(image.size.width.rounded())) x \(Int(image.size.height.rounded()))"
    }
}
