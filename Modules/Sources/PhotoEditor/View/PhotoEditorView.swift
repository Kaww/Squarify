import SwiftUI
import Design
import Localization

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
    @State private var showBorderSizeInputAlertView = false
    @State private var borderSizeAlertValue: Int? = nil

    // Toolbar
    @State private var currentImageIndex = 0

    // Edition
    @State private var selectedBorderColorMode: BorderColorMode = .color
    @State private var selectedBorderColor: Color = .white
    @State private var selectedBorderSizeMode: BorderSizeMode = .proportional
    @State private var selectedBorderValue: Double = 0
    @State private var previewBorderSize: Double = 0
    @State private var previewBoxingSize: CGSize = .zero

    private let minBorderValue: Double = 0
    private var maxBorderValue: Double {
        switch selectedBorderSizeMode {
        case .fixed:
            let largestSize: Int = _imagesToEdit.reduce(into: 100, { partialResult, image in
                let imageLargestSide = Int(image.size.largestSide)
                if partialResult < imageLargestSide {
                    partialResult = imageLargestSide
                }
            })
            return Double(Int(largestSize / 4))

        case .proportional:
            return 25
        }
    }

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
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isFinished {
                    Spacer()
                } else if editingImages.isEmpty {
                    thumbnailsLoadingView
                } else {
                    loadedView
                        .disabled(isProcessing)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: finish) {
                        Text("_cancel_button_label".localized)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.sunglow)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("_editor_title_label".localized)
                        .font(.system(size: 18, weight: .medium))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("_export_finished_alert_title".localized, isPresented: $showExportFinishedAlert) {
            Button("_back_home_button_label".localized, role: .cancel, action: finish)
            Button("_open_photos_gallery_button_label".localized, action: openPhotoApp)
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea(.keyboard)
        .onChange(of: currentImageIndex) { oldValue, newValue in
            currentImageDidChanged(newImage: editingImages[newValue].image)
        }
        .onChange(of: selectedBorderValue) { oldValue, newValue in
            borderValueDidChanged(newValue: newValue)
        }
        .onChange(of: selectedBorderSizeMode) { oldValue, newValue in
            borderSizeModeDidChanged()
        }
    }

    // MARK: - Views

    private var thumbnailsLoadingView: some View {
        GeometryReader { proxy in
            VStack {
                Text("_loading_images_label".localized)
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.sunglow)
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
        photoFrameView(image: editingImages[currentImageIndex].thumbnail)
            .transition(loadedViewSpringTransition(delay: 0))
            .padding(.bottom, 8)

        photoPreviewNavigationActions
            .padding(.horizontal, 4)
            .padding(.bottom, 16)
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
        .padding(.horizontal)
        .padding(.vertical, 8)

        Text("_photos_saved_in_gallery_message".localized)
            .font(.system(size: 12, weight: .regular))
            .opacity(0.5)
            .transition(loadedViewSpringTransition(delay: 0.4))
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
                    .padding(.leading, 4)
            }
            .buttonStyle(.plain)
            .disabled(currentImageIndex <= 0)

            Text(String(
                format: "_image_x_of_y_label".localized,
                "\(currentImageIndex + 1)",
                "\(editingImages.count)",
                "\(editingImages[currentImageIndex].sizeDescription)"
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
            .disabled(currentImageIndex == editingImages.count - 1)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(
            Capsule(style: .circular)
                .fill(.ultraThinMaterial)
        )
    }

    private func photoFrameView(image: UIImage) -> some View {
        GeometryReader { proxy in
            borderColorView
                .overlay {
                    if case .imageBlur = selectedBorderColorMode {
                        let enlarged = BorderColorMode.blurEnlargedSize(photoSize: proxy.size)
                        let scale = enlarged.width / proxy.size.width
                        Image(uiImage: image)
                            .resizable()
                            .scaleEffect(scale)
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 2 * BorderColorMode.blurAmountFor(photoSize: proxy.size))
                            .transition(.scale.animation(.easeOut(duration: 0.3)))
                    }
                }
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(previewBorderSize)
                        .onAppear { previewBoxingSize = proxy.size }
                        .onChange(of: proxy.size) { previewBoxingSize = $1 }
                }
                .border(tooDarkImagePreviewBorder, width: 1)
                .animation(.linear(duration: 0.1), value: selectedBorderColor)
        }
        .aspectRatio(contentMode: .fit)
        .clipped()
    }

    var tooDarkImagePreviewBorder: Color {
        guard selectedBorderColorMode == .color else { return .clear }
        return selectedBorderColor.isDark()
        ? .white.opacity(0.4)
        : .clear
    }

    var borderColorView: some View {
        ZStack {
            selectedBorderColor
                .zIndex(0)

            if case .imageBlur = selectedBorderColorMode {
                Color.white
                    .zIndex(1)
                    .transition(.opacity.animation(.linear(duration: 0.3)))
            }
        }
    }

    private var configView: some View {
        VStack(spacing: 8) {
            borderColorConfigItem
            borderSizeModeConfigItem
            borderSizeConfigItem
        }
        .padding(.horizontal)
    }

    private var borderColorConfigItem: some View {
        HStack {
            Image(systemName: "paintpalette.fill")
                .frame(width: 20)
            
            Text("_boder_color_picker_label".localized)
                .font(.system(size: 16, weight: .medium, design: .rounded))

            Spacer()

//            if case .color = selectedBorderColorMode {
                ColorPicker(
                    "",
                    selection: $selectedBorderColor,
                    supportsOpacity: false
                )
                .foregroundStyle(.white)
//            }

//            Menu {
//                Picker("", selection: $selectedBorderColorMode) {
//                    ForEach(BorderColorMode.allCases, id: \.title) { mode in
//                        Label(
//                            title: { Text(mode.title) },
//                            icon: { mode.icon }
//                        )
//                        .tag(mode)
//                    }
//                }
//            } label: {
//                Text(selectedBorderColorMode.title)
//                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                    .configPickerLabelStyle()
//            }
        }
    }

    private var borderSizeModeConfigItem: some View {
        HStack {
            HStack {
                Image(systemName: "square.dashed")
                    .frame(width: 20)
                Text("_border_mode_label".localized)
            }
            .foregroundStyle(.white)
            .font(.system(size: 16, weight: .medium, design: .rounded))

            Spacer()

            Menu {
                Picker("_mode_picker_label".localized, selection: $selectedBorderSizeMode) {
                    ForEach(BorderSizeMode.allCases) { mode in
                        Label(
                            title: { Text(mode.title) },
                            icon: { mode.icon }
                        )
                        .tag(mode)
                    }
                }
            } label: {
                Text(selectedBorderSizeMode.title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .configPickerLabelStyle()
            }
        }
    }

    private var borderSizeConfigItem: some View {
        VStack(spacing: 8) {
            HStack {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .frame(width: 20)
                    Text("_border_size_label".localized)
                }
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .medium, design: .rounded))

                Spacer()

                Button(action: { showBorderSizeInputAlertView = true }) {
                    Text("\(Int(selectedBorderValue)) \(selectedBorderSizeMode.unit)")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .configPickerLabelStyle()
                }
                .alert("_border_size_label".localized, isPresented: $showBorderSizeInputAlertView) {
                    TextField("_border_size_placeholder".localized, value: $borderSizeAlertValue, format: .number)
                        .keyboardType(.numberPad)
                        .foregroundStyle(.blue)

                    Button("_apply_button_label".localized) {
                        if let borderSizeAlertValue {
                            let newValue = Double(borderSizeAlertValue)
                            selectedBorderValue = newValue >= Double(maxBorderValue) ? Double(maxBorderValue) : newValue
                        }

                        borderSizeAlertValue = nil
                    }

                    Button("_cancel_button_label".localized, role: .cancel) {
                        borderSizeAlertValue = nil
                    }
                }
            }

            HStack(spacing: 16) {
                Text("\(Int(minBorderValue))")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))

                Slider(value: $selectedBorderValue, in: minBorderValue...maxBorderValue, step: 1)
                    .tint(.sunglow)

                Text("\(Int(maxBorderValue))")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
            }
        }
    }

    // MARK: - Border Calculations

    private func updateBorderSize(
        selectedBorderValue: Double,
        image: UIImage,
        animate: Bool = true
    ) {
        let imageLargestSide = image.size.largestSide
        let borderValue: Double

        switch selectedBorderSizeMode {
        case .fixed:
            borderValue = selectedBorderValue

        case .proportional:
            borderValue = selectedBorderValue / 100 * imageLargestSide
        }

        let previewBorderRatio = borderValue / imageLargestSide

        let animation = animate ? Animation.spring(response: 0.4, dampingFraction: 0.6) : nil
        withAnimation(animation) {
            previewBorderSize = previewBorderRatio * previewBoxingSize.largestSide
        }
    }

    private func currentImageDidChanged(newImage: UIImage) {
        updateBorderSize(
            selectedBorderValue: selectedBorderValue,
            image: newImage,
            animate: false
        )
    }

    private func borderValueDidChanged(newValue: Double) {
        updateBorderSize(
            selectedBorderValue: newValue,
            image: editingImages[currentImageIndex].image
        )
    }

    private func borderSizeModeDidChanged() {
        selectedBorderValue = minBorderValue
        updateBorderSize(
            selectedBorderValue: selectedBorderValue,
            image: editingImages[currentImageIndex].image
        )
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
        
        let params = ImageSaverParameters(
            images: editingImages.map(\.image),
            borderValue: selectedBorderValue,
            borderSizeMode: selectedBorderSizeMode,
            borderColorMode: selectedBorderColorMode,
            borderColor: UIColor(selectedBorderColor)
        )
        imageSaver.save(withParams: params) {
            isProcessing = false
            showExportFinishedAlert = true
        }
    }

    private func finish() {
        closeAnimation {
            onCancel()
        }
    }

    private func openPhotoApp() {
        closeAnimation {
            onCancel()
            if let photoAppURL = URL(string:"photos-redirect://") {
                UIApplication.shared.open(photoAppURL)
            }
        }
    }

    private func closeAnimation(completion: @escaping () -> Void) {
        Task { @MainActor in
            self.isFinished = true
            try? await Task.sleep(for: .seconds(0.4))
            completion()
        }
    }
}

#Preview {
    PhotoEditorView(
        imagesToEdit: [
            UIImage(resource: .img1),
            UIImage(resource: .img2),
            UIImage(resource: .img3)
        ],
        imageSaver: MockImageSaver(),
        thumbnailLoader: MockThumbnailLoader(),
        onCancel: {}
    )
}
