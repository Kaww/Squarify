import UIKit

extension UIImage {
    func blurred(amount: CGFloat) -> UIImage {
        guard let cgImage else { return self }
        let inputImage = CIImage(cgImage: cgImage)

        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(amount, forKey: "inputRadius")
        guard let result = (filter?.value(forKey: kCIOutputImageKey) as? CIImage) else { return self }

        guard let newCGImage = CIContext(options: nil).createCGImage(result, from: inputImage.extent) else { return self }
        let retVal = UIImage(cgImage: newCGImage, scale: self.scale, orientation: self.imageOrientation)
        return retVal
    }
}
