import SwiftUI
import Design

struct ExportButton: View {

    enum LoadingState {
        case idle
        case processing
        case done
    }

    private var loadingState: LoadingState
    private var numberOfImages: Int
    private var numberOfSavedImages: Int
    private var onTap: () -> Void

    init(
        loadingState: LoadingState,
        numberOfImages: Int,
        numberOfSavedImages: Int,
        onTap: @escaping () -> Void
    ) {
        self.loadingState = loadingState
        self.numberOfImages = numberOfImages
        self.numberOfSavedImages = numberOfSavedImages
        self.onTap = onTap
    }

    var body: some View {
        Button(action: handleTap) {
            Capsule(style: .continuous)
                .foregroundStyle(loadingState == .done ? .green : .sunglow)
                .frame(height: 40)
                .overlay { overlay }
                .clipped()
                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: loadingState)
        }
        .buttonStyle(.plain)
    }

    private var overlay: some View {
        ZStack {
            switch loadingState {
            case .idle:
                exportButtonLabel
            case .processing:
                exportButtonProcessingLabel
            case .done:
                doneLabel
            }
        }
    }

    private func handleTap() {
        if loadingState == .idle {
            onTap()
        }
    }

    private var exportButtonProcessingLabel: some View {
        HStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .transition(.opacity)
                .tint(.black)

            Text(String(
                format: "_exporting_label".localized,
                "\(numberOfSavedImages)",
                "\(numberOfImages)"
            ))
            .contentTransition(.numericText(value: Double(-numberOfSavedImages)))
            .animation(.default, value: numberOfSavedImages)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.black)
        }
        .transition(.push(from: .top).combined(with: .opacity))
    }

    private var exportButtonLabel: some View {
        Label("_export_all_photos_label".localized, systemImage: "square.and.arrow.up")
            .labelStyle(.titleAndIcon)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.black)
            .transition(.push(from: .top).combined(with: .opacity))
    }

    private var doneLabel: some View {
        Label("_export_done_label".localized, systemImage: "checkmark")
            .labelStyle(.titleAndIcon)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .transition(.push(from: .top).combined(with: .opacity))
    }
}

#Preview {
    ExportButtonPreview()
}

private struct ExportButtonPreview: View {

    @State private var loadingState = ExportButton.LoadingState.idle
    @State private var numberOfSavedImages = 0
    private let numberOfImages = 9

    var body: some View {
        VStack {
            ExportButton(
                loadingState: loadingState,
                numberOfImages: numberOfImages,
                numberOfSavedImages: numberOfSavedImages,
                onTap: {
                    loadingState = .processing
                }
            )
            .padding()

            Button(action: { numberOfSavedImages += 1 }) {
                Text("increment".localized)
            }

            Button(action: {
                loadingState = .idle
                numberOfSavedImages = 0
            }) {
                Text("reset".localized)
            }
        }
        .onChangeOf(numberOfSavedImages) { _ in
            if numberOfSavedImages == numberOfImages {
                loadingState = .done
            }
        }
    }
}
