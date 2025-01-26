import Foundation
import SwiftUI
import Utils
import RevenueCat
import RevenueCatUI
import ConfettiSwiftUI

/// App Icons that user can choose
///
/// App Icons are stored in app's Asset Catalog
/// - `rawValue` defines the icon's name as it is in the app's Asset Catalog
/// - `displayTitle` defines a title to be displayed to describe the icon
/// - `image` loads an `Image` from the module's Asset Catalog
enum AppIcon: String, CaseIterable, Identifiable {
  case `default` = "AppIcon"
  case insta = "insta"
  case green = "green"
  case pink = "pink"
  case multi = "multi"

  var id: String { rawValue }

  var displayTitle: String {
    switch self {
    case .default:
      "_app_icon_default".localized
    case .insta:
      "Insta"
    case .green:
      "Green"
    case .pink:
      "Pink"
    case .multi:
      "Multi"
    }
  }

  var image: Image {
    Image(self.rawValue, bundle: .module)
  }
}

struct AppIconsPickerView: View {

  @Environment(ProPlanService.self) private var proPlanService

  @State private var currentIconName: String? = ""
  @State private var showPaywall = false
  @State private var confettiCannonTrigger: Int = 0

  var body: some View {
    VStack(alignment: .leading) {
      Text("_app_icons".localized)
        .font(.system(size: 30, weight: .black))
        .padding(.top)

      ScrollView {
        ForEach(AppIcon.allCases) { icon in
          Button(action: { switchTo(icon) }) {
            HStack(spacing: 16) {
              icon.image
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                .shadow(radius: 10)

              Text(icon.displayTitle)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

              Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .foregroundStyle(.green)
                .background(
                  Circle()
                    .foregroundStyle(Color.white)
                    .frame(width: 22, height: 22)
                )
                .scaleEffect(isCurrent(icon) ? 1 : 0)
                .opacity(isCurrent(icon) ? 1 : 0)
                .padding(.leading, 20)
            }
            .animation(.spring(duration: 0.4), value: currentIconName)
            .padding(10)
            .background(
              RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundStyle(.gray.opacity(0.2))
            )
          }
          .buttonStyle(.plain)
        }
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical)
    .frame(maxWidth: .infinity, alignment: .leading)
    .presentationCornerRadius(50)
    .presentationDragIndicator(.visible)
    .onAppear {
      currentIconName = UIApplication.shared.alternateIconName
    }
    .sheet(isPresented: $showPaywall) {
      PaywallView()
        .onPurchaseCompleted { _ in
          showPaywall = false
          confettiCannonTrigger += 1
          proPlanService.refresh()
        }
        .onRestoreCompleted { _ in
          showPaywall = false
          confettiCannonTrigger += 1
          proPlanService.refresh()
        }
    }
    .confettiCannon(
      counter: $confettiCannonTrigger,
      num: 50,
      confettiSize: 15,
      radius: UIScreen.main.bounds.height * 3/4,
      repetitions: 2,
      repetitionInterval: 1
    )
  }

  func isCurrent(_ icon: AppIcon) -> Bool {
    let iconName: String? = icon == .default ? nil : icon.rawValue
    return iconName == currentIconName
  }

  private func switchTo(_ icon: AppIcon) {
    guard proPlanService.currentStatus == .pro else {
      showPaywall = true
      return
    }

    let iconName: String? = icon == .default ? nil : icon.rawValue

    guard
      UIApplication.shared.supportsAlternateIcons,
      UIApplication.shared.alternateIconName != iconName
    else {
      return
    }

    UIApplication.shared.setAlternateIconName(iconName) { error in
      if let error = error {
        print(error.localizedDescription)
      } else {
        currentIconName = iconName
      }
    }
  }
}

#Preview {
  Color.clear
    .sheet(isPresented: .constant(true), content: {
      AppIconsPickerView()
    })
}
