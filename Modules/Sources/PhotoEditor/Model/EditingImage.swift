import UIKit

struct EditingImage {
  let image: UIImage
  let thumbnail: UIImage
  
  var sizeDescription: String {
    "\(Int(image.size.width.rounded())) x \(Int(image.size.height.rounded()))"
  }
  
  static var mock: Self {
    let image = mockImage(width: 1452, height: 2128)
    return EditingImage(image: image, thumbnail: image)
  }

  private static func mockImage(width: CGFloat, height: CGFloat) -> UIImage {
    let size = CGSize(width: width, height: height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    let emptyImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return emptyImage ?? UIImage()
  }

}
