import SwiftUI

struct PhotoPreviewActionBar: View {
  @Binding var currentImageIndex: Int
  let numberOfImages: Int
  let imageExportSize: CGSize
  let borderAmount: Int

  var body: some View {
    HStack(spacing: 0) {
      leftButton
      centerInfosView
      rightButton
    }
    .padding(.horizontal, 4)
    .padding(.vertical, 4)
    .background(
      ZStack {
        Capsule(style: .continuous)
          .fill(.ultraThinMaterial)

        Capsule(style: .continuous)
          .stroke(
            LinearGradient(
              colors: [.clear, .white.opacity(0.3)],
              startPoint: .top,
              endPoint: .bottom
            ),
            lineWidth: 0.5
          )
      }
    )
    .padding(.horizontal, 2)
  }

  // MARK: Views

  private var leftButton: some View {
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
  }

  private var centerInfosView: some View {
    HStack(spacing: 10) {
      HStack(spacing: 4) {
        Image(systemName: "photo")
        Text("\(currentImageIndex + 1)/\(numberOfImages)")
      }
      .contentTransition(.numericText(value: Double(-currentImageIndex)))
      .animation(.spring, value: currentImageIndex)

      Capsule()
        .frame(width: 1.5, height: 14)
        .opacity(0.3)

      Text("\(Int(imageExportSize.width.rounded())) x \(Int(imageExportSize.height.rounded()))")

      Capsule()
        .frame(width: 1.5, height: 14)
        .opacity(0.3)

      HStack(spacing: 4) {
        Image(systemName: "square.dashed")
        Text("\(borderAmount)px")
          .frame(width: 48, alignment: .leading)
          .contentTransition(.numericText(value: Double(borderAmount)))
          .animation(.spring, value: borderAmount)
      }
    }
    .layoutPriority(1)
    .monospacedDigit()
    .font(.system(size: 12, weight: .medium))
  }

  private var rightButton: some View {
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

  // MARK: Actions

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
  @State var value: CGFloat = 230

  var body: some View {
    VStack(spacing: 90) {
      PhotoPreviewActionBar(
        currentImageIndex: $toto,
        numberOfImages: 4,
        imageExportSize: CGSize(width: 1452, height: 2128),
        borderAmount: Int(value)
      )
      .preferredColorScheme(.dark)

      Slider(value: $value, in: 0...2431)
    }
  }
}

#Preview {
  PreviewView()
}
