import SwiftUI

public struct IsPressedButtonStyle: ButtonStyle {

    @Binding var isPressed: Bool

    public init(isPressed: Binding<Bool>) {
        _isPressed = isPressed
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                isPressed = newValue
            }
    }
}
