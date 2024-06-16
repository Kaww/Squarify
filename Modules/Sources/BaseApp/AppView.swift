import SwiftUI
import Design
import PhotoEditor
import PhotoPicker
import Localization
import Utils

public struct AppView: View {

    @State private var photoSelection: PhotoSelection?

    private let proPlanService: ProPlanService

    public init() {
        proPlanService = ProPlanService()
        proPlanService.configure()
    }

    public var body: some View {
        NavigationStack {
            PhotoPickerView(selection: $photoSelection)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background { BackgroundBlurView() }
                .toolbar { toolbarContent }
                .fullScreenCover(item: $photoSelection) { selection in
                    PhotoEditorView(
                        imagesToEdit: selection.photos,
                        imageSaver: DefaultImageSaver(),
                        thumbnailLoader: DefaultThumbnailLoader(),
                        onCancel: {
                            photoSelection = nil
                        }
                    )
                }
        }
        .environment(proPlanService)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Text("Squarify")
                .foregroundStyle(.white)
                .font(.system(size: 40, weight: .black))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 2, y: 2)
        }

        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink {
                SettingsView()
            } label: {
                Label("_settings".localized, systemImage: "gearshape.fill")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .contentShape(Rectangle())
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 2, y: 2)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    AppView()
}
