import SwiftUI
import PhotosUI
import Utils

// TODO: Move to style
public extension Color {
    static let aquamarine = Color(uiColor: UIColor(red: 2/255, green: 255/255, blue: 176/255, alpha: 1))
    static let risdBlue = Color(uiColor: UIColor(red: 2/255, green: 77/255, blue: 255/255, alpha: 1))
}

public struct PhotoPickerView: View {

    @State private var pickedPhotos: [PhotosPickerItem] = []
    
    @State private var isLoading = false
    @State private var isPressingButton = false
    @State private var hasAppeared = false

    @Binding var selection: PhotoSelection?

    public init(selection: Binding<PhotoSelection?>) {
        _selection = selection
    }

    public var body: some View {
        VStack {
            titleView
            photosPickerButton
        }
        .padding(16)
        .onChange(of: pickedPhotos) {
            process(pickerItems: $1)
        }
        .task {
            try? await Task.sleep(for: .seconds(0.2))
            hasAppeared = true
        }
    }

    private var titleView: some View {
        Text("Framr")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 40, weight: .black))
    }

    private var photosPickerButton: some View {
        VStack(spacing: 16) {
            PhotosPicker(
                selection: $pickedPhotos,
                maxSelectionCount: 10,
                selectionBehavior: .ordered,
                matching: .images,
                preferredItemEncoding: .current,
                photoLibrary: .shared()
            ) {
                photosPickerLabel
            }
            .buttonStyle(IsPressedButtonStyle(isPressed: $isPressingButton))
            .photosPickerStyle(.presentation)
            .photosPickerDisabledCapabilities([.stagingArea])
            .transition(.opacity.combined(with: .scale))
            .disabled(isLoading)

            Text("Pick photos")
                .font(.system(size: 20, weight: .medium))
                .opacity(isLoading ? 0 : 1)
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 20)
                .animation(.spring(duration: 0.4, bounce: 0.5).delay(0.2), value: hasAppeared)
        }
        .frame(maxHeight: .infinity)
    }

    private var photosPickerLabel: some View {
        Circle()
            .fill(Color.risdBlue)
            .brightness(isPressingButton ? -0.1 : 0)
            .shadow(color: .risdBlue.opacity(0.3), radius: 20, x: 0.0, y: 10)
            .frame(width: 90, height: 90)
            .scaleEffect(isPressingButton ? 0.9 : 1)
            .animation(.spring(duration: 0.2), value: isPressingButton)
            .scaleEffect(hasAppeared ? 1 : 0)
            .animation(.spring(duration: 0.4, bounce: 0.5), value: hasAppeared)
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .controlSize(.large)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(.white)
                        .scaleEffect(isPressingButton ? 0.90 : 1)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.spring(duration: 0.3), value: isPressingButton)
                        .scaleEffect(hasAppeared ? 1 : 0)
                        .animation(.spring(duration: 0.6, bounce: 0.5), value: hasAppeared)
                }
            }
            .animation(.spring(.bouncy(duration: 0.4)), value: isLoading)
    }

    private func process(pickerItems: [PhotosPickerItem]) {
        if pickedPhotos.isEmpty { return }
        isLoading = true
        Task {
            var photos = [UIImage]()
            for item in pickerItems {
                if let data = try? await item.loadTransferable(type: Data.self), let photo = UIImage(data: data) {
                    photos.append(photo)
                }
            }
            try? await Task.sleep(for: .seconds(1))

            isLoading = false
            pickedPhotos = []
            selection = PhotoSelection(photos: photos, id: Date.now.description)
        }
    }
}

#Preview {
    PhotoPickerView(selection: .constant(nil))
}
