import SwiftUI
import Design
import PhotoEditor
import PhotoPicker
import Localization
import Utils

public struct AppView: View {

    @State private var photoSelection: PhotoSelection?
    @State private var hasAppeared = false

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
                .task {
                    guard !hasAppeared else { return }
                    try? await Task.sleep(for: .seconds(1))
                    hasAppeared = true
                }
        }
        .environment(proPlanService)
    }

    private var showProText: Bool {
        proPlanService.currentStatus == .pro && hasAppeared
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("Squarify")
                    .font(.system(size: 40, weight: .black))

                Text("Pro")
                    .font(.system(size: 14, weight: .regular))
                    .opacity(showProText ? 1 : 0)
                    .scaleEffect(showProText ? 1 : 0.5, anchor: .leading)
                    .rotationEffect(.degrees(showProText ? 0 : 50), anchor: .leading)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.4), value: hasAppeared)
            .foregroundStyle(.white)
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
