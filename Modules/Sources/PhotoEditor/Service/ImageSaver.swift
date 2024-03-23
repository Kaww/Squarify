import Foundation
import CoreGraphics
import UIKit

/// Source: [Medium post](https://medium.com/the-traveled-ios-developers-guide/uigraphicsimagerenderer-fe40edc3a464).
class ImageSaver: NSObject, ObservableObject {

    @Published var numberOfSavedImages: Int = 0

    func save(
        _ images: [UIImage],
        borderSize: CGFloat,
        completion: @escaping () -> Void
    ) {
        print(Date.now)
        Task {
            for image in images {
                autoreleasepool {
                    saveV3(image, borderSize: borderSize)
                }
                try? await Task.sleep(for: .seconds(0.5)) // TODO: Adapt sleep to each image size
            }
            await MainActor.run {
                completion()
                numberOfSavedImages = 0
            }
        }
        print(Date.now)
    }

    private func saveV3(_ photo: UIImage, borderSize: CGFloat) {
        let renderingInfos = ImageRenderingInfos(
            size: CGSize(
                width: photo.size.largestSide,
                height: photo.size.largestSide
            ),
            borderWidth: borderSize,
            borderColor: .white
        )
        let totalSize = renderingInfos.size

        // Image scaling calculations
        let targetSize = renderingInfos.innerImageAvailableSize
        let widthRatio = targetSize.width / photo.size.width
        let heightRatio = targetSize.height / photo.size.height

        let scaleFactor = min(widthRatio, heightRatio)
        let scaledImageSize = CGSize(
            width: (photo.size.width * scaleFactor).rounded(),
            height: (photo.size.height * scaleFactor).rounded()
        )

        // Start rendering
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: renderingInfos.size, format: format)

        let framedImage = renderer.image { context in
            renderingInfos.borderColor.setFill()

            let fullRect = CGRect(x: 0, y: 0, width: totalSize.width, height: totalSize.width)
            context.fill(fullRect)

            let imageRect = CGRect(
                x: (totalSize.width - scaledImageSize.width) / 2,
                y: (totalSize.height - scaledImageSize.height) / 2,
                width: scaledImageSize.width,
                height: scaledImageSize.height
            )

            photo.draw(in: imageRect)
        }

        UIImageWriteToSavedPhotosAlbum(framedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc
    private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        print("\(image) saved.")
        
        Task { @MainActor in
            self.numberOfSavedImages += 1
        }
    }
}

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
}

struct ImageRenderingInfos {
    let size: CGSize
    let borderWidth: CGFloat
    let borderColor: UIColor

    var innerImageAvailableSize: CGSize {
        .init(
            width: size.width - borderWidth,
            height: size.height - borderWidth
        )
    }
}

extension CGSize {
    var largestSide: CGFloat {
        width > height ? width : height
    }
}

//private func save(_ photo: UIImage, borderSize: CGFloat) {
//    let renderingInfos = ImageRenderingInfos(
//        size: CGSize(
//            width: photo.size.largestSide,
//            height: photo.size.largestSide
//        ),
//        borderWidth: borderSize,
//        borderColor: .white
//    )
//    let scaledImage = photo.scalePreservingAspectRatio(targetSize: renderingInfos.innerImageAvailableSize)
//    let imageSize = scaledImage.size
//    let totalSize = renderingInfos.size
//
//    UIGraphicsBeginImageContext(totalSize)
//
//    let context = UIGraphicsGetCurrentContext()
//    context?.setFillColor(UIColor.white.cgColor)
//    context?.fill([.init(x: 0, y: 0, width: totalSize.width, height: totalSize.width)])
//
//    // Calculate image position
//    let imageRect = CGRect(
//        x: (totalSize.width - imageSize.width) / 2,
//        y: (totalSize.height - imageSize.height) / 2,
//        width: imageSize.width,
//        height: imageSize.height
//    )
//    scaledImage.draw(in: imageRect)
//
//    guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
//        print("could not create new image")
//        UIGraphicsEndImageContext()
//        return
//    }
//
//    UIGraphicsEndImageContext()
//
//    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil)
//    print("\(photo) saved.")
//}
//
//private func saveV2(_ photo: UIImage, borderSize: CGFloat) {
//    let renderingInfos = ImageRenderingInfos(
//        size: CGSize(
//            width: photo.size.largestSide,
//            height: photo.size.largestSide
//        ),
//        borderWidth: borderSize,
//        borderColor: .white
//    )
//
//    // TODO: extract that to only use 1 renderer in the process
//    let scaledImage = photo.scalePreservingAspectRatio(targetSize: renderingInfos.innerImageAvailableSize)
//    let imageSize = scaledImage.size
//    let totalSize = renderingInfos.size
//
//    let format = UIGraphicsImageRendererFormat()
//    format.scale = 1
//
//    let renderer = UIGraphicsImageRenderer(size: totalSize, format: format)
//    let framedImage = renderer.image { context in
//        UIColor.white.setFill()
//        let frameRect = CGRect(x: 0, y: 0, width: totalSize.width, height: totalSize.width)
//        context.fill(frameRect)
//
//        let imageRect = CGRect(
//            x: (totalSize.width - imageSize.width) / 2,
//            y: (totalSize.height - imageSize.height) / 2,
//            width: imageSize.width,
//            height: imageSize.height
//        )
//
//        scaledImage.draw(in: imageRect)
//    }
//
//    UIImageWriteToSavedPhotosAlbum(framedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
//    print("\(photo) saved.")
//}
