import SwiftUI

extension View {
    func configPickerLabelStyle() -> some View {
        self.padding(.vertical, 5)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .tint(.sunglow)
    }
}
