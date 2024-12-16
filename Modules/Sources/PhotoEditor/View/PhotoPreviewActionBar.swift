import SwiftUI

struct PhotoPreviewActionBar: View {
  @Binding var currentImageIndex: Int
  let numberOfImages: Int
  let currentImage: EditingImage

  var body: some View {
    HStack {
      Button(action: showPreviousPhoto) {
        Image(systemName: "chevron.left")
          .font(.system(size: 20, weight: .medium))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity, alignment: .leading)
          .contentShape(Rectangle())
          .padding(.leading, 4)
      }
      .buttonStyle(.plain)
      .disabled(currentImageIndex <= 0)

      Group {
        Text(String(
          format: "_image_x_of_y_label".localized,
          "\(currentImageIndex + 1)",
          "\(numberOfImages)"
        ))
        .frame(maxWidth: .infinity, alignment: .center)
        .contentTransition(.numericText(value: Double(-currentImageIndex)))
        .animation(.spring, value: currentImageIndex)

        Text("\(currentImage.sizeDescription)")
          .frame(maxWidth: .infinity, alignment: .center)
      }
      .monospacedDigit()
      .font(.system(size: 12, weight: .medium))

      Button(action: showNextPhoto) {
        Image(systemName: "chevron.right")
          .font(.system(size: 20, weight: .medium))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity, alignment: .trailing)
          .contentShape(Rectangle())
          .padding(.trailing, 4)
      }
      .buttonStyle(.plain)
      .disabled(currentImageIndex == numberOfImages - 1)
    }
    .padding(.horizontal, 4)
    .padding(.vertical, 4)
    .background(
      ZStack {
        Capsule(style: .continuous)
          .fill(.ultraThinMaterial)

        Capsule(style: .continuous)
          .stroke(LinearGradient(
            colors: [.clear, .white.opacity(0.3)],
            startPoint: .top,
            endPoint: .bottom
          ), lineWidth: 0.5)
      }
    )
    .padding(.horizontal, 2)
  }

  private func showPreviousPhoto() {
    if currentImageIndex > 0 {
      currentImageIndex -= 1
    }
  }

  private func showNextPhoto() {
    if currentImageIndex < numberOfImages - 1 {
      currentImageIndex += 1
    }
  }
}

private struct PreviewView: View {
  @State var toto: Int = 1

  var body: some View {
    PhotoPreviewActionBar(
      currentImageIndex: $toto,
      numberOfImages: 4,
      currentImage: .mock
    )
    .preferredColorScheme(.dark)
  }
}

#Preview {
  PreviewView()
}
