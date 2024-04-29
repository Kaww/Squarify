import UIKit

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: (size.width * scaleFactor).rounded(),
            height: (size.height * scaleFactor).rounded()
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(size: scaledImageSize, format: format)

        return renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
    }

    func blurred(amount: CGFloat) -> UIImage {
        //  Create our blurred image
        let context = CIContext(options: nil)
        guard let cgImage else { return self }
        let inputImage = CIImage(cgImage: cgImage)
        //  Setting up Gaussian Blur

        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(amount, forKey: "inputRadius")
        let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage

       /*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
        *  up exactly to the bounds of our original image */

        let newCGImage = context.createCGImage(result ?? CIImage(), from: inputImage.extent)
        let retVal = UIImage(cgImage: newCGImage!, scale: self.scale, orientation: self.imageOrientation)
        return retVal
    }
}
