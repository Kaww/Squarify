import SwiftUI
import Design

struct ExportButton: View {

    private var isProcessing: Bool
    private var numberOfImages: Int
    private var numberOfSavedImages: Int
    private var onTap: () -> Void

    init(
        isProcessing: Bool,
        numberOfImages: Int,
        numberOfSavedImages: Int,
        onTap: @escaping () -> Void
    ) {
        self.isProcessing = isProcessing
        self.numberOfImages = numberOfImages
        self.numberOfSavedImages = numberOfSavedImages
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .foregroundStyle(.sunglow)
                .frame(height: 40)
                .overlay {
                    if isProcessing {
                        exportButtonProcessingLabel
                    } else {
                        exportButtonLabel
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isProcessing)
        }
        .buttonStyle(.plain)
    }

    private var exportButtonProcessingLabel: some View {
        HStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .transition(.opacity)
                .tint(.black)

            Text("Exporting... \(numberOfSavedImages) / \(numberOfImages)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.black)
        }
    }

    private var exportButtonLabel: some View {
        Label("Export all photos", systemImage: "square.and.arrow.up")
            .labelStyle(.titleAndIcon)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.black)
            .transition(.offset(y: 20).combined(with: .opacity))
    }
}

#Preview {
    ExportButtonPreview()
}

private struct ExportButtonPreview: View {

    @State private var isProcessing = false
    @State private var numberOfSavedImages = 0

    var body: some View {
        VStack {
            ExportButton(
                isProcessing: isProcessing,
                numberOfImages: 10,
                numberOfSavedImages: numberOfSavedImages,
                onTap: { isProcessing.toggle() }
            )
            .padding()

            Button(action: { numberOfSavedImages += 1 }) {
                Text("Increment")
            }

            Button(action: {
                isProcessing = false
                numberOfSavedImages = 0
            }) {
                Text("Reset")
            }
        }
    }
}
