import SwiftUI

extension View {
    func configPickerLabelStyle() -> some View {
        self.padding(.vertical, 5)
            .padding(.horizontal, 12)
            .background(
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .brightness(0.02)
            )
            .tint(.sunglow)
    }
}
