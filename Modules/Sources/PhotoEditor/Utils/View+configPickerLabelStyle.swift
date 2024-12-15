import SwiftUI

extension View {
  func configPickerLabelStyle() -> some View {
    self.padding(.vertical, 5)
      .padding(.horizontal, 12)
      .background(
        ZStack {
          Capsule(style: .continuous)
            .fill(.ultraThinMaterial)
            .brightness(0.02)

          Capsule(style: .continuous)
            .stroke(LinearGradient(
              colors: [.clear, .sunglow.opacity(0.3)],
              startPoint: .top,
              endPoint: .bottom
            ), lineWidth: 0.5)
        }
      )
      .tint(.sunglow)
  }
}
