import CoreGraphics
import UIKit

/// Source: [Medium post](https://medium.com/the-traveled-ios-developers-guide/uigraphicsimagerenderer-fe40edc3a464).
public class DefaultImageSaver: NSObject, ImageSaver {

    private struct ImageRenderingInfos {
        let size: CGSize
        let borderWidth: CGFloat
        let borderColor: UIColor

        var innerImageAvailableSize: CGSize {
            .init(
                width: size.width - 2 * borderWidth,
                height: size.height - 2 * borderWidth
            )
        }
    }

    @Published public var numberOfSavedImages: Int = 0

    public func save(withParams params: ImageSaverParameters, completion: @escaping () -> Void) {
        Task {
            for image in params.images {
                autoreleasepool {
                    saveV3(
                        image,
                        borderValue: params.borderValue,
                        borderMode: params.borderMode,
                        borderColor: params.color
                    )
                }
                try? await Task.sleep(for: .seconds(0.5)) // TODO: Adapt sleep to each image size
            }
            await MainActor.run {
                completion()
                numberOfSavedImages = 0
            }
        }
    }

    private func saveV3(
        _ photo: UIImage,
        borderValue: CGFloat,
        borderMode: BorderMode,
        borderColor: UIColor
    ) {

        // Calculate rendering border size
        let borderSize: CGFloat
        
        switch borderMode {
        case .fixed:
            borderSize = borderValue
        case .proportional:
            borderSize = borderValue / 100 * photo.size.largestSide
        }

        // Setup rendering infos
        let renderingInfos = ImageRenderingInfos(
            size: CGSize(
                width: photo.size.largestSide,
                height: photo.size.largestSide
            ),
            borderWidth: borderSize,
            borderColor: borderColor
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

extension CGSize {
    var largestSide: CGFloat {
        width > height ? width : height
    }
}
