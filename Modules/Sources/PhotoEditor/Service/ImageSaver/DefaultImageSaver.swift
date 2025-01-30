import CoreGraphics
import UIKit

/// Source: [Medium post](https://medium.com/the-traveled-ios-developers-guide/uigraphicsimagerenderer-fe40edc3a464).
public class DefaultImageSaver: NSObject, ImageSaver {

  @Published public var numberOfSavedImages: Int = 0

  public func save(withParams params: ImageSaverParameters, completion: @escaping () -> Void) {
    Task {
      for image in params.images {
        autoreleasepool {
          saveV4(
            image,
            aspectRatio: params.aspectRatio,
            frameAmount: params.frameAmount,
            frameSizeMode: params.frameSizeMode,
            frameColorMode: params.frameColorMode,
            frameColor: params.frameColor
          )
        }
        try? await Task.sleep(for: .seconds(0.5))
      }
      await MainActor.run {
        completion()
      }
    }
  }

  public func resetState() {
    numberOfSavedImages = 0
  }

  // MARK: Save V4

  private func saveV4(
    _ sourceImage: UIImage,
    aspectRatio: AspectRatioMode,
    frameAmount: CGFloat,
    frameSizeMode: FrameSizeMode,
    frameColorMode: FrameColorMode,
    frameColor: UIColor
  ) {
    // Get canvas witdh or height based on format
    let sourceImgSize = sourceImage.size
    let canvasSize = aspectRatio.canvasSizeFor(imageSize: sourceImgSize)
    let canvasSizeValue: CGFloat
    switch aspectRatio {
    case .square, .instaPortrait:
      canvasSizeValue = canvasSize.width
    case .instaLandscape:
      canvasSizeValue = canvasSize.height
    }

    // Calculate real frame amount value based on image size
    let rawFrameAmount: CGFloat
    switch frameSizeMode {
    case .fixed:
      rawFrameAmount = frameAmount
    case .proportional:
      rawFrameAmount = frameAmount / 100 * canvasSizeValue
    }

    // Apply borders insets to image
    let imageTouchingSides = sourceImgSize.touchingSides(forFrameAspectRatio: aspectRatio)
    let insettedImageSize: CGSize
    switch imageTouchingSides {
    case .vertical:
      let h1 = sourceImgSize.height
      let h2 = h1 - 2 * rawFrameAmount
      let w1 = sourceImgSize.width
      let w2 = w1 * h2 / h1
      insettedImageSize = CGSize(width: w2, height: h2)

    case .horizontal:
      let w1 = sourceImgSize.width
      let w2 = w1 - 2 * rawFrameAmount
      let h1 = sourceImgSize.height
      let h2 = h1 * w2 / w1
      insettedImageSize = CGSize(width: w2, height: h2)
    }

    // Calculate image position
    let renderingData = (
      canvasRect: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height),
      imageRect: CGRect(
        x: canvasSize.width / 2 - insettedImageSize.width / 2,
        y: canvasSize.height / 2 - insettedImageSize.height / 2,
        width: insettedImageSize.width,
        height: insettedImageSize.height
      )
    )

    // Prepare rendering
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    let renderer = UIGraphicsImageRenderer(
      size: canvasSize.rounded,
      format: format
    )

    // Rendering
    let renderedImage = renderer.image { context in

      // Draw background
      let canvasRect = renderingData.canvasRect.rounded()

      switch frameColorMode {
      case .color:
        frameColor.setFill()
        context.fill(canvasRect)

      case .imageBlur:
        UIColor.white.setFill()
        context.fill(canvasRect)

        let blurAmount = FrameColorMode.blurAmountFor(photoSize: sourceImage.size)
        let enlargedRect = FrameColorMode
          .scale(imageSize: sourceImgSize, frameSize: canvasSize)
          .centered(with: canvasRect)
          .rounded()

        sourceImage
          .blurred(amount: blurAmount)
          .draw(in: enlargedRect)
      }

      // Draw image
      let imageRect = renderingData.imageRect.rounded()
      sourceImage.draw(in: imageRect)
    }

    // Save image
    UIImageWriteToSavedPhotosAlbum(renderedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }

  @objc
  private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
    Task { @MainActor in
      self.numberOfSavedImages += 1
    }
  }
}
