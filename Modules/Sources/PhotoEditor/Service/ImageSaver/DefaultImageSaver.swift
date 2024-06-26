import CoreGraphics
import UIKit

/// Source: [Medium post](https://medium.com/the-traveled-ios-developers-guide/uigraphicsimagerenderer-fe40edc3a464).
public class DefaultImageSaver: NSObject, ImageSaver {

    private struct ImageRenderingInfos {
        let size: CGSize
        let borderWidth: CGFloat

        var imageSizeWithinBorders: CGSize {
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
                        borderSizeMode: params.borderSizeMode,
                        borderColorMode: params.borderColorMode,
                        borderColor: params.borderColor
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
        _ sourceImage: UIImage,
        borderValue: CGFloat,
        borderSizeMode: BorderSizeMode,
        borderColorMode: BorderColorMode,
        borderColor: UIColor
    ) {
        // Calculate border size
        let borderWidth: CGFloat
        
        switch borderSizeMode {
        case .fixed:
            borderWidth = borderValue
        
        case .proportional:
            borderWidth = borderValue / 100 * sourceImage.size.largestSide
        }

        // Setup rendering infos
        let renderingInfos = ImageRenderingInfos(
            size: CGSize(
                width: sourceImage.size.largestSide,
                height: sourceImage.size.largestSide
            ),
            borderWidth: borderWidth
        )
        let finalImageSize = renderingInfos.size

        // Image scaling calculations
        let targetImageSize = renderingInfos.imageSizeWithinBorders
        let widthRatio = targetImageSize.width / sourceImage.size.width
        let heightRatio = targetImageSize.height / sourceImage.size.height

        let scaleFactor = min(widthRatio, heightRatio)
        let scaledImageSize = CGSize(
            width: sourceImage.size.width * scaleFactor,
            height: sourceImage.size.height * scaleFactor
        )

        // Start rendering
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: renderingInfos.size, format: format)

        let finalImage = renderer.image { context in

            let finalImageRect = CGRect(x: 0, y: 0, width: finalImageSize.width, height: finalImageSize.width)

            // Write background
            switch borderColorMode {
            case .color:
                borderColor.setFill()
                context.fill(finalImageRect)

            case .imageBlur:
                UIColor.white.setFill()
                context.fill(finalImageRect)

                let blurAmount = BorderColorMode.blurAmountFor(photoSize: sourceImage.size)
                let enlargedRect = BorderColorMode
                    .blurEnlargedSize(photoSize: sourceImage.size)
                    .centered(with: finalImageRect)
                    .rounded()

                sourceImage
                    .blurred(amount: blurAmount)
                    .draw(in: enlargedRect)
            }

            // Write image
            let imageRect = CGRect(
                x: (finalImageSize.width - scaledImageSize.width) / 2,
                y: (finalImageSize.height - scaledImageSize.height) / 2,
                width: scaledImageSize.width,
                height: scaledImageSize.height
            ).rounded()
            sourceImage.draw(in: imageRect)
        }

        UIImageWriteToSavedPhotosAlbum(finalImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc
    private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        Task { @MainActor in
            self.numberOfSavedImages += 1
        }
    }
}
