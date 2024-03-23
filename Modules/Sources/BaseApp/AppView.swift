import SwiftUI
import PhotoEditor

struct PhotoSelection: Identifiable {
    let photos: [UIImage]
    let id: String
}

public struct AppView: View {

    @State private var photoSelection: PhotoSelection?

    public init() {}

    public var body: some View {
        PhotoPickerView(selection: $photoSelection)
            .fullScreenCover(item: $photoSelection) { selection in
                PhotoEditorView(
                    imagesToEdit: selection.photos,
                    onCancel: {
                        photoSelection = nil
                    }
                )
            }
    }
}

#Preview {
    AppView()
}
