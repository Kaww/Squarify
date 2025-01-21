import UIKit

public struct ImageSaverParameters {
  let images: [UIImage]
  let aspectRatio: AspectRatioMode
  let frameAmount: CGFloat
  let frameSizeMode: FrameSizeMode
  let frameColorMode: FrameColorMode
  let frameColor: UIColor
}
