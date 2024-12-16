import SwiftUI
import Photos
import Design
import Localization
import Utils
import RevenueCat
import RevenueCatUI
import ConfettiSwiftUI

public struct PhotoEditorView<Saver: ImageSaver>: View {

  @Environment(ProPlanService.self) private var proPlanService

  // Services
  @StateObject private var imageSaver: Saver
  private let thumbnailLoader: any ThumbnailLoader

  // Data
  private let _imagesToEdit: [UIImage]
  @State private var editingImages: [EditingImage] = []
  private let onCancel: () -> Void

  // Visual State
  @State private var processingState: ExportButton.LoadingState = .idle
  @State private var showExportFinishedAlert = false
  @State private var isFinished = false
  @State private var showDoYouLikePrompt = false
  @State private var showNoPhotoAccessAlert = false
  @State private var showPaywall = false
  @State private var confettiCannonTrigger: Int = 0

  // Toolbar
  @State private var currentImageIndex: Int = 0

  // Edition
  @State private var selectedAspectRatioMode: AspectRatioMode = .square
  @State private var selectedFrameColorMode: FrameColorMode = .color
  @State private var selectedFrameColor: Color = FrameColorMode.defaultColor
  @State private var selectedFrameSizeMode: FrameSizeMode = .proportional
  @State private var selectedFrameAmount: Double = 0
  @State private var previewFrameAmount: Double = 0
  @State private var previewBoxingSize: CGSize = .zero

  private let minFrameAmount: Double = 0
  private var maxFrameAmount: Double {
    switch selectedFrameSizeMode {
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

  var exportFinishedTitleText: String {
    var text = "_export_finished_alert_title".localized
    if ProcessInfo.processInfo.isiOSAppOnMac {
      text += "\n"
      text += "_photos_saved_in_gallery_message".localized
    }
    return text
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

  // MARK: - BODY

  public var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        if isFinished {
          Spacer()
        } else if editingImages.isEmpty {
          loadingView
        } else {
          loadedView
        }
      }
      .toolbar { toolbarContent }
      .navigationBarTitleDisplayMode(.inline)
      .ignoresSafeArea(.keyboard)
    }
    .overlay(alignment: .bottom) { configPanelView }
    .overlay { processingExportOverlay }
    .alert(
      exportFinishedTitleText,
      isPresented: $showExportFinishedAlert,
      actions: {
        Button("_back_home_button_label".localized, role: .cancel, action: finish)
        if !ProcessInfo.processInfo.isiOSAppOnMac {
          Button("_open_photos_gallery_button_label".localized, action: openPhotoApp)
        }
      },
      message: {
        if !ProcessInfo.processInfo.isiOSAppOnMac {
          Text("_photos_saved_in_gallery_message".localized)
        }
      }
    )
    .alert("_photo_access_is_not_granted".localized, isPresented: $showNoPhotoAccessAlert) {
      Button("_back_home_button_label".localized, role: .cancel, action: finish)
      Button("_go_to_privacy_app_settings".localized, action: goToAppPrivacySettings)
    }
    .preferredColorScheme(.dark)
    .onChange(of: currentImageIndex) { oldValue, newValue in
      currentImageDidChanged(newImage: editingImages[newValue].image)
    }
    .onChange(of: selectedFrameAmount) { oldValue, newValue in
      frameAmountDidChanged(newValue: newValue)
    }
    .onChange(of: selectedFrameSizeMode) { oldValue, newValue in
      frameSizeModeDidChanged()
    }
    .task {
      if AppStoreReview.canAsk() {
        try? await Task.sleep(for: .seconds(0.5))
        showDoYouLikePrompt = true
      }
    }
    .sheet(isPresented: $showDoYouLikePrompt) { doYouLikePromptView }
    .sheet(isPresented: $showPaywall) { paywallView }
  }

  // MARK: - SHEETS CONTENT

  private var doYouLikePromptView: some View {
    DoYouLikePromptView(
      onLike: {
        showDoYouLikePrompt = false
        AppStoreReview.ask()
      },
      onDislike: {
        AppStoreReview.recordAsked()
      },
      onClose: { showDoYouLikePrompt = false }
    )
  }

  private var paywallView: some View {
    PaywallView()
      .onPurchaseCompleted { _ in
        showPaywall = false
        confettiCannonTrigger += 1
        proPlanService.refresh()
      }
      .onRestoreCompleted { _ in
        showPaywall = false
        confettiCannonTrigger += 1
        proPlanService.refresh()
      }
  }

  // MARK: - TOOLBAR CONTENT

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
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

    ToolbarItem(placement: .topBarTrailing) {
      Button(action: saveImages) {
        Text("_export_button_label".localized)
          .font(.system(size: 18, weight: .bold))
          .foregroundStyle(Color.aquamarine)
      }
    }
  }

  // MARK: - VIEWS

  private var loadingView: some View {
    GeometryReader { proxy in
      VStack {
        Text("_loading_images_label".localized)
        ProgressView()
          .progressViewStyle(.circular)
          .tint(.sunglow)
          .controlSize(.large)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .task { await loadThumbnails(ofSize: proxy.size) }
    }
    .transition(.opacity.combined(with: .scale).animation(.spring))
  }

  @ViewBuilder
  private var loadedView: some View {
    photoFrameView(image: editingImages[currentImageIndex].thumbnail)
      .transition(loadedViewSpringTransition(delay: 0))
      .padding(.bottom, 8)

    PhotoPreviewActionBar(
      currentImageIndex: $currentImageIndex,
      numberOfImages: editingImages.count,
      currentImage: editingImages[currentImageIndex]
    )
    .transition(loadedViewSpringTransition(delay: 0.1))

    Spacer()
  }

  @ViewBuilder
  private var configPanelView: some View {
    if !editingImages.isEmpty && !isFinished {
      ConfigPanelView(
        aspectRatioMode: $selectedAspectRatioMode,
        frameColor: $selectedFrameColor,
        frameColorMode: $selectedFrameColorMode,
        frameSizeMode: $selectedFrameSizeMode,
        frameAmount: $selectedFrameAmount,
        minFrameAmount: minFrameAmount,
        maxFrameAmount: maxFrameAmount,
        isPro: proPlanService.currentStatus == .pro
      )
      .transition(loadedViewSpringTransition(delay: 0.2))
      .disabled(processingState == .processing)
      .background(
        Color.clear
          .confettiCannon(
            counter: $confettiCannonTrigger,
            num: 50,
            confettiSize: 15,
            radius: UIScreen.main.bounds.height * 3/4,
            repetitions: 2,
            repetitionInterval: 1
          )
      )
    }
  }

  private func loadedViewSpringTransition(delay: TimeInterval) -> AnyTransition {
    if thumbnailLoader is MockThumbnailLoader {
      return .identity
    }
    let spring = Animation.spring.delay(delay)
    return .opacity.combined(with: .scale).animation(spring)
  }

  private func photoFrameView(image: UIImage) -> some View {
    GeometryReader { proxy in
      frameColorView
        .overlay {
          if case .imageBlur = selectedFrameColorMode {
            let enlarged = FrameColorMode.blurEnlargedSize(photoSize: proxy.size)
            let scale = enlarged.width / proxy.size.width
            Image(uiImage: image)
              .resizable()
              .scaleEffect(scale)
              .aspectRatio(contentMode: .fill)
              .blur(radius: 2 * FrameColorMode.blurAmountFor(photoSize: proxy.size))
              .transition(.scale.animation(.easeOut(duration: 0.3)))
          }
        }
        .overlay {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(previewFrameAmount)
            .onAppear { previewBoxingSize = proxy.size }
            .onChange(of: proxy.size) { previewBoxingSize = $1 }
        }
        .border(tooDarkImagePreviewBorder, width: 1)
        .animation(.linear(duration: 0.1), value: selectedFrameColor)
    }
    .aspectRatio(contentMode: .fit)
    .clipped()
  }

  private var tooDarkImagePreviewBorder: Color {
    guard selectedFrameColorMode == .color else { return .clear }
    return selectedFrameColor.isDark()
    ? .white.opacity(0.4)
    : .clear
  }

  private var frameColorView: some View {
    ZStack {
      selectedFrameColor
        .zIndex(0)

      if case .imageBlur = selectedFrameColorMode {
        Color.white
          .zIndex(1)
          .transition(.opacity.animation(.linear(duration: 0.3)))
      }
    }
  }

  @ViewBuilder
  private var processingExportOverlay: some View {
    if processingState == .processing || processingState == .done {
      ZStack {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .foregroundStyle(.thinMaterial)

        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .stroke(LinearGradient(
            colors: [.clear, processingExportOverlayBorderColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ), lineWidth: processingState == .done ? 2 : 1)
          .animation(.linear(duration: 0.2), value: processingState)

        VStack(spacing: 24) {
          ZStack {
            if processingState == .processing {
              ProgressView()
                .progressViewStyle(.circular)
                .transition(.opacity)
                .tint(.white)
                .controlSize(.large)
                .transition(
                  .opacity.combined(with: .scale(0.5))
                  .animation(.linear(duration: 0.2))
                )
            } else if processingState == .done {
              Image(systemName: "checkmark")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.aquamarine)
                .transition(
                  .opacity.combined(with: .scale(0.5))
                  .animation(.spring(response: 0.3, dampingFraction: 0.5))
                )
            }
          }
          .frame(height: 30)

          VStack(spacing: 8) {
            Text(String(
              format: "_exporting_label".localized,
              "\(imageSaver.numberOfSavedImages)",
              "\(editingImages.count)"
            ))
            .contentTransition(.numericText(value: Double(-imageSaver.numberOfSavedImages)))
            .animation(.default, value: imageSaver.numberOfSavedImages)
            .font(.system(size: 20, weight: .semibold, design: .default))
            .monospacedDigit()

            Text("_photos_are_saved_in_gallery_message".localized)
              .font(.system(size: 12, weight: .regular))
              .opacity(0.5)
              .padding(.horizontal)
              .multilineTextAlignment(.center)
          }
        }
        .padding(.top, 20)
      }
      .frame(width: 180, height: 180)
      .transition(
        .opacity.combined(with: .scale(0.5))
        .animation(.spring(response: 0.3, dampingFraction: 0.5))
      )
    }
  }

  private var processingExportOverlayBorderColor: Color {
    switch processingState {
    case .idle: return .clear
    case .processing: return .white.opacity(0.5)
    case .done: return .aquamarine
    }
  }

  // MARK: - FRAME CALCULATIONS

  private func updateFrameAmount(
    selectedFrameAmount: Double,
    image: UIImage,
    animate: Bool = true
  ) {
    let imageLargestSide = image.size.largestSide
    let frameAmount: Double

    switch selectedFrameSizeMode {
    case .fixed:
      frameAmount = selectedFrameAmount

    case .proportional:
      frameAmount = selectedFrameAmount / 100 * imageLargestSide
    }

    let previewFrameRatio = frameAmount / imageLargestSide

    let animation = animate ? Animation.spring(response: 0.4, dampingFraction: 0.6) : nil
    withAnimation(animation) {
      previewFrameAmount = previewFrameRatio * previewBoxingSize.largestSide
    }
  }

  private func currentImageDidChanged(newImage: UIImage) {
    updateFrameAmount(
      selectedFrameAmount: selectedFrameAmount,
      image: newImage,
      animate: false
    )
  }

  private func frameAmountDidChanged(newValue: Double) {
    updateFrameAmount(
      selectedFrameAmount: newValue,
      image: editingImages[currentImageIndex].image
    )
  }

  private func frameSizeModeDidChanged() {
    selectedFrameAmount = minFrameAmount
    updateFrameAmount(
      selectedFrameAmount: selectedFrameAmount,
      image: editingImages[currentImageIndex].image
    )
  }

  // MARK: - ACTIONS

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

  private func saveImages() {
    let isUserPro = proPlanService.currentStatus == .pro
    let hasUsedProFeatures = selectedFrameColorMode == .imageBlur

    if !isUserPro && hasUsedProFeatures {
      showPaywall = true
      return
    }

    processingState = .processing

    Task {
      try? await Task.sleep(for: .seconds(0.5))

      let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)

      switch status {
      case .authorized:
        let params = ImageSaverParameters(
          images: editingImages.map(\.image),
          frameAmount: selectedFrameAmount,
          frameSizeMode: selectedFrameSizeMode,
          frameColorMode: selectedFrameColorMode,
          frameColor: UIColor(selectedFrameColor)
        )
        imageSaver.save(withParams: params) {
          processingState = .done
          AppStoreReview.recordCompletedEdition()
          Task {
            try? await Task.sleep(for: .seconds(0.8))
            processingState = .idle
            showExportFinishedAlert = true
          }
        }

      case .limited, .notDetermined, .restricted, .denied:
        showNoPhotoAccessAlert = true

      @unknown default: break
      }
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
      if !ProcessInfo.processInfo.isiOSAppOnMac {
        if let photoAppURL = URL(string:"photos-redirect://") {
          UIApplication.shared.open(photoAppURL)
        }
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

  private func goToAppPrivacySettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString),
          UIApplication.shared.canOpenURL(url) else {
      assertionFailure("Not able to open App privacy settings")
      return
    }

    UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
  .environment(ProPlanService())
}
