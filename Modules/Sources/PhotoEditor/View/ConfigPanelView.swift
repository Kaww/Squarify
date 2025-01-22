import SwiftUI
import Utils

struct ConfigPanelView: View {

  enum Position {
    case open, wrapped
  }

  // MARK: Params
  @Binding var aspectRatioMode: AspectRatioMode
  @Binding var frameColor: Color
  @Binding var frameColorMode: FrameColorMode
  @Binding var frameSizeMode: FrameSizeMode
  @Binding var frameAmount: Double
  let minFrameAmount: Double
  let maxFrameAmount: Double
  let isPro: Bool

  // MARK: Frame Amount Input Alert
  @State private var showFrameAmountInputView = false
  @State private var frameAmountInputValue: Int? = nil

  // MARK: Panel Drag Gesture
  @State private var panelHeight: CGFloat = 0
  @State private var dragOffset: CGFloat = 0
  @State private var positionOffset: CGFloat = 0
  @State private var panelPosition: Position = .open
  @State private var panelPositionDidChanged = false
  private var dragLimitToPin: CGFloat {
    switch panelPosition {
    case .open: return panelHeight / 3
    case .wrapped: return panelHeight / 4
    }
  }

  // MARK: - Body

  var body: some View {
    VStack(spacing: 8) {
      grapIndicator
      aspectRationModeConfigItem
      frameColorConfigItem
      frameSizeModeConfigItem
      frameAmountConfigItem
    }
    .padding(.horizontal)
    .padding(.top, 12)
    .padding(.bottom)
    .background(backgroundView)
    .padding(.horizontal, 2)
    .padding(.bottom, 2)
    .background(heightReaderView)
    .gesture(
      DragGesture(minimumDistance: 1, coordinateSpace: .global)
        .onChanged { value in
          // Updates dragOffset with rubber band feeling
          HapticsEngine.shared.prepare()
          dragOffset = calculateDragOffset(translation: value.translation)
        }
        .onEnded { value in
          // Change positionOffset depending on the end position
          let currentDragOffset = calculateDragOffset(translation: value.translation)
          var newPositionOffset: CGFloat? = nil

          switch panelPosition {
          case .open:
            if currentDragOffset > dragLimitToPin {
              panelPosition = .wrapped
              newPositionOffset = panelHeight - panelHeight/3
              panelPositionDidChanged = true
            }
          case .wrapped:
            if currentDragOffset < -dragLimitToPin {
              panelPosition = .open
              newPositionOffset = 0
              panelPositionDidChanged = true
            }
          }

          if panelPositionDidChanged {
            HapticsEngine.shared.selectionChanged()
            panelPositionDidChanged = false
          }

          withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            dragOffset = 0
            if let newPositionOffset {
              positionOffset = newPositionOffset
            }
          }
        }
    )
    .offset(y: dragOffset)
    .offset(y: positionOffset)
  }

  func calculateDragOffset(translation: CGSize) -> CGFloat {
    let dragLimit: CGFloat = panelHeight * 1.5
    let xOff = translation.width
    let yOff = translation.height
    let dist = sqrt(xOff*xOff + yOff*yOff);
    let factor = 1 / (dist / dragLimit + 1)
    return translation.height * factor
  }

  // MARK: - Views

  private var backgroundView: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(.ultraThinMaterial)

      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .stroke(LinearGradient(
          colors: [.clear, .white.opacity(0.3)],
          startPoint: .top,
          endPoint: .bottom
        ), lineWidth: 0.5)
    }
  }

  private var heightReaderView: some View {
    GeometryReader { proxy in
      Color.clear
        .onAppear {
          panelHeight = proxy.size.height
        }
        .onChange(of: proxy.size, initial: true) { _, newSize in
          panelHeight = newSize.height
        }
    }
  }

  private var grapIndicator: some View {
    Capsule(style: .continuous)
      .fill(.white.opacity(0.5))
      .frame(width: 28, height: 4)
  }

  // MARK: Aspect Ratio

  private var aspectRationModeConfigItem: some View {
    HStack {
      HStack {
        Image(systemName: "aspectratio")
        Text("_aspect_ratio_mode_picker_label".localized)
      }
      .foregroundStyle(.white)
      .font(.system(size: 16, weight: .medium, design: .rounded))
      .frame(maxWidth: .infinity, alignment: .leading)

      Menu {
        Picker("_mode_picker_label".localized, selection: $aspectRatioMode) {
          ForEach(AspectRatioMode.allCases) { mode in
            Label(
              title: { Text(aspectRatioLabelTitle(mode: mode)) },
              icon: { mode.icon }
            )
            .tag(mode)
          }
        }
      } label: {
        Text(aspectRatioLabelTitle(mode: aspectRatioMode))
          .font(.system(size: 16, weight: .medium, design: .rounded))
          .configPickerLabelStyle()
          .frame(width: 165, alignment: .trailing)
          .animation(.spring(duration: 0.3), value: aspectRatioMode)
      }
    }
  }

  private func aspectRatioLabelTitle(mode: AspectRatioMode) -> String {
    mode != .square && !isPro
    ? mode.title + " (⭑ Pro)"
    : mode.title
  }


  // MARK: Frame Color

  private var frameColorConfigItem: some View {
    HStack {
      Image(systemName: "paintpalette.fill")
        .frame(width: 20)

      Text("_boder_color_picker_label".localized)
        .font(.system(size: 16, weight: .medium, design: .rounded))
        .frame(maxWidth: .infinity, alignment: .leading)

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
    ? mode.title + " (⭑ Pro)"
    : mode.title
  }

  // MARK: Frame Size Mode

  private var frameSizeModeConfigItem: some View {
    HStack {
      HStack {
        Image(systemName: "square.dashed")
          .frame(width: 20)
        Text("_frame_size_mode_label".localized)
      }
      .foregroundStyle(.white)
      .font(.system(size: 16, weight: .medium, design: .rounded))
      .frame(maxWidth: .infinity, alignment: .leading)

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
          .frame(width: 130, alignment: .trailing)
          .animation(.spring(duration: 0.3), value: frameSizeMode)
      }
    }
  }

  // MARK: Frame Size Amount

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
        .frame(maxWidth: .infinity, alignment: .leading)

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

// MARK: - Preview

private struct PreviewView: View {
  @State private var selecteAspectRatioMode: AspectRatioMode = .square
  @State private var selectedFrameColor: Color = FrameColorMode.defaultColor
  @State private var selectedFrameColorMode: FrameColorMode = .color
  @State private var selectedFrameSizeMode: FrameSizeMode = .proportional
  @State private var selectedFrameAmount: Double = 0
  private let minFrameAmount: Double = 0
  private let maxFrameAmount: Double = 1000

  var body: some View {
    VStack {
      Color.white
        .aspectRatio(selecteAspectRatioMode.ratio, contentMode: .fit)
        .padding(.top, 50)
        .animation(.easeOut(duration: 0.2), value: selecteAspectRatioMode)
      Spacer()
    }
    .overlay(alignment: .bottom) {
      ConfigPanelView(
        aspectRatioMode: $selecteAspectRatioMode,
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
}

#Preview {
  PreviewView()
    .preferredColorScheme(.dark)
}
