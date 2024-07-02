import SwiftUI

struct ConfigPanelView: View {

    @Binding var frameColor: Color
    @Binding var frameColorMode: FrameColorMode
    @Binding var frameSizeMode: FrameSizeMode
    @Binding var frameAmount: Double
    let minFrameAmount: Double
    let maxFrameAmount: Double
    let isPro: Bool

    @State private var showFrameAmountInputView = false
    @State private var frameAmountInputValue: Int? = nil

    var body: some View {
        VStack(spacing: 8) {
            frameColorConfigItem
            frameSizeModeConfigItem
            frameAmountConfigItem
        }
        .padding(.horizontal)
    }

    private var frameColorConfigItem: some View {
        HStack {
            Image(systemName: "paintpalette.fill")
                .frame(width: 20)

            Text("_boder_color_picker_label".localized)
                .font(.system(size: 16, weight: .medium, design: .rounded))

            Spacer()

            HStack(spacing: 0) {
                frameColorModeMenuView
                if case .color = frameColorMode {
                    colorPickerView
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: frameColorMode)
        }
    }

    private var colorPickerView: some View {
        ColorPicker(
            "",
            selection: $frameColor,
            supportsOpacity: false
        )
        .foregroundStyle(.white)
        .transition(.scale.combined(with: .offset(x: 50)).combined(with: .opacity))
        .frame(width: 40)
    }

    private var frameColorModeMenuView: some View {
        Menu {
            Picker("", selection: $frameColorMode) {
                ForEach(FrameColorMode.allCases, id: \.title) { mode in
                    Label(
                        title: { Text(frameColorModeLabelTitle(mode: mode)) },
                        icon: { mode.icon }
                    )
                    .tag(mode)
                }
            }
        } label: {
            Text(frameColorModeLabelTitle(mode: frameColorMode) )
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .configPickerLabelStyle()
                .frame(width: 120, alignment: .trailing)
                .animation(.spring(duration: 0.3), value: frameColorMode)
        }
    }

    private func frameColorModeLabelTitle(mode: FrameColorMode) -> String {
        mode == .imageBlur && !isPro
        ? mode.title + " (pro)"
        : mode.title
    }

    private var frameSizeModeConfigItem: some View {
        HStack {
            HStack {
                Image(systemName: "square.dashed")
                    .frame(width: 20)
                Text("_frame_size_mode_label".localized)
            }
            .foregroundStyle(.white)
            .font(.system(size: 16, weight: .medium, design: .rounded))

            Spacer()

            Menu {
                Picker("_mode_picker_label".localized, selection: $frameSizeMode) {
                    ForEach(FrameSizeMode.allCases) { mode in
                        Label(
                            title: { Text(mode.title) },
                            icon: { mode.icon }
                        )
                        .tag(mode)
                    }
                }
            } label: {
                Text(frameSizeMode.title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .configPickerLabelStyle()
                    .frame(width: 120, alignment: .trailing)
                    .animation(.spring(duration: 0.3), value: frameSizeMode)
            }
        }
    }

    private var frameAmountConfigItem: some View {
        VStack(spacing: 8) {
            HStack {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .frame(width: 20)
                    Text("_frame_amount_label".localized)
                }
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .medium, design: .rounded))

                Spacer()

                Button(action: { showFrameAmountInputView = true }) {
                    HStack(spacing: 5) {
                        Text("\(Int(frameAmount))")
                            .contentTransition(.numericText(value: frameAmount))

                        Text("\(frameSizeMode.unit)")
                    }
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .configPickerLabelStyle()
                    .frame(width: 120, alignment: .trailing)
                    .animation(.spring(duration: 0.3), value: frameAmount)
                    .animation(.spring(duration: 0.3), value: frameSizeMode)
                }
                .alert("_frame_amount_label".localized, isPresented: $showFrameAmountInputView) {
                    TextField("_frame_amount_placeholder".localized, value: $frameAmountInputValue, format: .number)
                        .keyboardType(.numberPad)
                        .foregroundStyle(.blue)

                    Button("_apply_button_label".localized) {
                        if let frameAmountInputValue {
                            let newValue = Double(frameAmountInputValue)
                            frameAmount = newValue >= Double(maxFrameAmount) ? Double(maxFrameAmount) : newValue
                        }

                        frameAmountInputValue = nil
                    }

                    Button("_cancel_button_label".localized, role: .cancel) {
                        frameAmountInputValue = nil
                    }
                }
            }

            HStack(spacing: 16) {
                Text("\(Int(minFrameAmount))")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))

                Slider(value: $frameAmount, in: minFrameAmount...maxFrameAmount, step: 1)
                    .tint(.sunglow)

                Text("\(Int(maxFrameAmount))")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
            }
        }
    }
}

private struct PreviewView: View {
    @State private var selectedFrameColor: Color = FrameColorMode.defaultColor
    @State private var selectedFrameColorMode: FrameColorMode = .color
    @State private var selectedFrameSizeMode: FrameSizeMode = .proportional
    @State private var selectedFrameAmount: Double = 0
    private let minFrameAmount: Double = 0
    private let maxFrameAmount: Double = 1000

    var body: some View {
        ConfigPanelView(
            frameColor: $selectedFrameColor,
            frameColorMode: $selectedFrameColorMode,
            frameSizeMode: $selectedFrameSizeMode,
            frameAmount: $selectedFrameAmount,
            minFrameAmount: minFrameAmount,
            maxFrameAmount: maxFrameAmount,
            isPro: false
        )
    }
}

#Preview {
    PreviewView()
        .preferredColorScheme(.dark)
}
