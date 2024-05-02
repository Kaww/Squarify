import CoreGraphics
import UIKit

/// Source: [Medium post](https://medium.com/the-traveled-ios-developers-guide/uigraphicsimagerenderer-fe40edc3a464).
public class DefaultImageSaver: NSObject, ImageSaver {

    private struct ImageRenderingInfos {
        let size: CGSize
        let borderWidth: CGFloat

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
                        backgroundMode: params.backgroundMode,
                        backgroundColor: params.backgroundColor
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
        backgroundMode: BackgroundMode,
        backgroundColor: UIColor
    ) {
        // Calculate border size
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
            borderWidth: borderSize
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

            let fullRect = CGRect(x: 0, y: 0, width: totalSize.width, height: totalSize.width)

            // Write background
            switch backgroundMode {
            case .color:
                backgroundColor.setFill()
                context.fill(fullRect)

            case .imageBlur:
                UIColor.white.setFill()
                context.fill(fullRect)

                let blurAmount = BackgroundMode.blurAmountFor(photoSize: photo.size)
                let enlargedRect = BackgroundMode
                    .blurEnlargedSize(photoSize: photo.size)
                    .centered(in: fullRect)

                photo
                    .blurred(amount: blurAmount)
                    .draw(in: enlargedRect)
            }

            // Write image
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
