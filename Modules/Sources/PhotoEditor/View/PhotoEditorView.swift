import SwiftUI

struct EditingImage {
    let image: UIImage
    let thumbnail: UIImage
    
    var sizeDescription: String {
        "\(Int(image.size.width.rounded())) x \(Int(image.size.height.rounded()))"
    }
}

public struct PhotoEditorView<Saver: ImageSaver>: View {
    
    // Services
    @StateObject private var imageSaver: Saver
    private let thumbnailLoader: any ThumbnailLoader

    // Data
    private let _imagesToEdit: [UIImage]
    @State private var editingImages: [EditingImage] = []
    private let onCancel: () -> Void

    // Visual State
    @State private var isProcessing = false
    @State private var showExportFinishedAlert = false
    @State private var isFinished = false

    // Toolbar
    @State private var currentImageIndex = 0

    // Edition
    @State private var selectedBorderMode = BorderMode.fixed
    @State private var selectedBorderSize: Double = 0
    @State private var previewBorderSize: Double = 0
    @State private var renderingBorderSize: Double = 0
    @State private var previewBoxingSize: CGSize = .zero
    private let minBorder: Double = 0
    private let maxBorder: Double

    public init(
        imagesToEdit: [UIImage],
        imageSaver: Saver,
        thumbnailLoader: any ThumbnailLoader,
        onCancel: @escaping () -> Void
    ) {
        self._imagesToEdit = imagesToEdit
        self._imageSaver = .init(wrappedValue: imageSaver)
        self.thumbnailLoader = thumbnailLoader
        self.onCancel = onCancel

        let largestSize: Int = imagesToEdit.reduce(into: 100, { partialResult, image in
            let imageLargestSide = Int(image.size.largestSide)
            if partialResult < imageLargestSide {
                partialResult = imageLargestSide
            }
        })
        self.maxBorder = Double(Int(largestSize / 4))
    }

    public var body: some View {
        VStack {
            headerView
                .padding(.horizontal)
                .padding(.vertical)

            if isFinished {
                Spacer()
            } else if editingImages.isEmpty {
                thumbnailsLoadingView
            } else {
                loadedView
            }
        }
        .alert("Export finished", isPresented: $showExportFinishedAlert) {
            Button("Back home", role: .cancel, action: finish)
            Button("Show photos in gallery", action: openPhotoApp)
        }
        .preferredColorScheme(.dark)
        .onChange(of: selectedBorderSize) { oldValue, newValue in
            updateBorderSize(
                selectedBorderSize: newValue,
                previewBoxingSize: previewBoxingSize,
                image: editingImages[currentImageIndex].image
            )
        }
        .onChange(of: currentImageIndex) { oldValue, newValue in
            updateBorderSize(
                selectedBorderSize: selectedBorderSize,
                previewBoxingSize: previewBoxingSize,
                image: editingImages[newValue].image
            )
        }

    }

    // MARK: - Views

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

    private var thumbnailsLoadingView: some View {
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
                await loadThumbnails(ofSize: proxy.size)
            }
        }
        .transition(.opacity.combined(with: .scale).animation(.spring))
    }


    @ViewBuilder
    private var loadedView: some View {
        photoPreviewNavigationActions
            .padding(.horizontal)
            .transition(loadedViewSpringTransition(delay: 0))

        photoFrameView(image: editingImages[currentImageIndex].thumbnail)
            .padding(.bottom, 20)
            .transition(loadedViewSpringTransition(delay: 0.1))

        configView
            .transition(loadedViewSpringTransition(delay: 0.2))

        Spacer()

        ExportButton(
            isProcessing: isProcessing,
            numberOfImages: editingImages.count,
            numberOfSavedImages: imageSaver.numberOfSavedImages,
            onTap: saveImages
        )
        .transition(loadedViewSpringTransition(delay: 0.3))
        .padding()
    }

    private func loadedViewSpringTransition(delay: TimeInterval) -> AnyTransition {
        if thumbnailLoader is MockThumbnailLoader {
            return .identity
        }
        let spring = Animation.spring.delay(delay)
        return .opacity.combined(with: .scale).animation(spring)
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

            Text("Photo \(currentImageIndex + 1)/\(editingImages.count) • \(editingImages[currentImageIndex].sizeDescription)")
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
                        .padding(previewBorderSize)
                        .onAppear { previewBoxingSize = proxy.size }
                        .onChange(of: proxy.size) { previewBoxingSize = $1 }
                }
        }
        .aspectRatio(contentMode: .fit)
    }

    private var configView: some View {
        VStack(spacing: 16) {
            borderModeConfigItem
            borderSizeConfigItem
        }
        .padding(.horizontal)
    }

    private var borderModeConfigItem: some View {
        HStack {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .frame(width: 20)
                Text("Border Mode")
            }
            .foregroundStyle(.white)
            .font(.system(size: 16, weight: .medium, design: .rounded))

            Spacer()

            Menu {
                // TODO: handle proportional BorderMode
                Picker("Mode", selection: .constant(BorderMode.fixed)) {//$selectedBorderMode) {
                    ForEach(BorderMode.allCases) { mode in
                        Label(
                            title: { Text(mode.title) },
                            icon: { mode.icon }
                        )
                        .tag(mode)
                    }
                }
            } label: {
                Text(selectedBorderMode.title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .tint(.orange)
            }
        }
    }

    private var borderSizeConfigItem: some View {
        VStack(spacing: 8) {
            HStack {
                HStack {
                    Image(systemName: "square.dashed")
                        .frame(width: 20)
                    Text("Border Size")
                }
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .medium, design: .rounded))

                Spacer()

                Text("\(Int(selectedBorderSize))")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
            }

            HStack(spacing: 16) {
                Text("\(Int(minBorder))")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))

                Slider(value: $selectedBorderSize, in: minBorder...maxBorder, step: 1)
                    .tint(.white)

                Text("\(Int(maxBorder))")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
            }
        }
    }

    // MARK: - Border Calculations

    // TODO: handle changes of BorderMode
    private func updateBorderSize(
        selectedBorderSize: Double,
        previewBoxingSize: CGSize,
        image: UIImage
    ) {
        // Updates rendering border size
        renderingBorderSize = selectedBorderSize

        // Updates preview border size
        let imageLargestSide = image.size.largestSide
        let previewBorderRatio = selectedBorderSize / imageLargestSide
        previewBorderSize = previewBorderRatio * previewBoxingSize.largestSide
    }

    // MARK: - Actions

    private func loadThumbnails(ofSize size: CGSize) async {
        var newEditingImages = [EditingImage]()
        for image in _imagesToEdit {
            let thumbnail = await thumbnailLoader.loadThumbnail(ofSize: size, for: image)
            if let thumbnail {
                newEditingImages.append(EditingImage(image: image, thumbnail: thumbnail))
            }
        }
        self.editingImages = newEditingImages
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
        imageSaver.save(editingImages.map(\.image), borderSize: renderingBorderSize) {
            isProcessing = false
            showExportFinishedAlert = true
        }
    }

    private func finish() {
        Task { @MainActor in
            self.isFinished = true
            try? await Task.sleep(for: .seconds(0.4))
            onCancel()
        }
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
        imageSaver: MockImageSaver(),
        thumbnailLoader: MockThumbnailLoader(),
        onCancel: {}
    )
}
