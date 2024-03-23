import SwiftUI

struct EditingImage {
    let image: UIImage
    let thumbnail: UIImage
    
    var sizeDescription: String {
        "\(Int(image.size.width)) x \(Int(image.size.height))"
    }
}

public struct PhotoEditorView: View {
    @State private var isProcessing = false
    @State private var showExportFinishedAlert = false

    @State private var borderSize: Double = 0
    private let minBorder: Double = 0
    private let maxBorder: Double = 500

    @State private var currentImageIndex = 0
    private let imagesToEdit: [UIImage]
    @State private var editingImages: [EditingImage] = []

    private let onCancel: () -> Void

    @StateObject private var imageSaver = ImageSaver()

    public init(
        imagesToEdit: [UIImage],
        onCancel: @escaping () -> Void
    ) {
        self.imagesToEdit = imagesToEdit
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack {
            headerView
                .padding(.horizontal)
                .padding(.vertical)

            if editingImages.isEmpty {
                GeometryReader { proxy in
                    VStack {
                        Text("Loading images...")
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.orange)
                            .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task {
                        var newEditingImages = [EditingImage]()
                        for image in imagesToEdit {
                            let thumbnail = await image.byPreparingThumbnail(ofSize: proxy.size)
                            if let thumbnail {
                                newEditingImages.append(EditingImage(image: image, thumbnail: thumbnail))
                            }
                        }
                        self.editingImages = newEditingImages
                    }
                }
                .transition(.opacity.combined(with: .scale).animation(.spring))
            } else {
                photoPreviewNavigationActions
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale).animation(.spring.delay(0)))

                photoFrameView(image: editingImages[currentImageIndex].thumbnail)
                    .padding(.bottom, 20)
                    .transition(.opacity.combined(with: .scale).animation(.spring.delay(0.1)))

                configView
                    .transition(.opacity.combined(with: .scale).animation(.spring.delay(0.2)))

                Spacer()

                ExportButton(
                    isProcessing: isProcessing,
                    numberOfImages: imagesToEdit.count,
                    numberOfSavedImages: imageSaver.numberOfSavedImages,
                    onTap: saveImages
                )
                .transition(.opacity.combined(with: .scale).animation(.spring.delay(0.3)))
                .padding()
            }
        }
        .alert("Export finished", isPresented: $showExportFinishedAlert) {
            Button("Back home", role: .cancel, action: finish)
            Button("Show photos in gallery", action: openPhotoApp)
        }
        .preferredColorScheme(.dark)
    }

    private var headerView: some View {
        HStack() {
            Button(action: onCancel) {
                Image(systemName: "multiply")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(.white)
            }

            Spacer()
        }
        .overlay {
            Text("Editor")
                .font(.system(size: 18, weight: .medium))
        }
    }

    private var photoPreviewNavigationActions: some View {
        HStack {
            Button(action: showPreviousPhoto) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(currentImageIndex <= 0)

            let photo = imagesToEdit[currentImageIndex]
            Text("Photo \(currentImageIndex + 1)/\(editingImages.count) • \(Int(photo.size.width)) x \(Int(photo.size.height))")
                .monospacedDigit()
                .font(.system(size: 14, weight: .regular))
                .layoutPriority(1)

            Button(action: showNextPhoto) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(currentImageIndex == editingImages.count - 1)
        }
    }

    private func photoFrameView(image: UIImage) -> some View {
        GeometryReader { proxy in
            Color.white
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(borderSize)
                }
        }
        .aspectRatio(contentMode: .fit)
    }

    private var configView: some View {
        VStack {
            HStack {
                Text("Border")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .rounded))

                Spacer()

                Text("\(Int(borderSize))")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
            }

            HStack(spacing: 16) {
                Text("\(Int(minBorder))")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))

                Slider(value: $borderSize, in: minBorder...maxBorder, step: 1)
                    .tint(.white)

                Text("\(Int(maxBorder))")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
            }
        }
        .padding(.horizontal)
    }

    private func showPreviousPhoto() {
        if currentImageIndex > 0 {
            currentImageIndex -= 1
        }
    }

    private func showNextPhoto() {
        if currentImageIndex < editingImages.count - 1 {
            currentImageIndex += 1
        }
    }

    private func saveImages() {
        isProcessing = true
        imageSaver.save(editingImages.map(\.image), borderSize: borderSize) {
            isProcessing = false
            showExportFinishedAlert = true
        }
    }

    private func finish() {
        onCancel()
    }

    private func openPhotoApp() {
        onCancel()
        if let photoAppURL = URL(string:"photos-redirect://") {
            UIApplication.shared.open(photoAppURL)
        }
    }
}

#Preview {
    PhotoEditorView(
        imagesToEdit: [
            UIImage(systemName: "photo")!,
            UIImage(systemName: "camera.macro")!,
            UIImage(systemName: "pawprint.fill")!
        ],
        onCancel: {}
    )
}
