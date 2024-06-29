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

            Text(String(
                format: "_image_x_of_y_label".localized,
                "\(currentImageIndex + 1)",
                "\(numberOfImages)",
                "\(currentImage.sizeDescription)"
            ))
            .monospacedDigit()
            .font(.system(size: 12, weight: .medium))
            .layoutPriority(1)

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
            Capsule(style: .circular)
                .fill(.ultraThinMaterial)
        )
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

#Preview {
    PhotoPreviewActionBar(
        currentImageIndex: .constant(2),
        numberOfImages: 4,
        currentImage: .mock
    )
    .preferredColorScheme(.dark)
}
