import Foundation
import SwiftUI
import Utils

enum AppIcons: String, CaseIterable, Identifiable {
    case squarify = "AppIcon"
    case squarifyPro = "AppIconPro"

    var id: String { rawValue }

    var iconName: String? {
        switch self {
        case .squarify:
            return nil

        default:
            return rawValue
        }
    }

    var title: String {
        switch self {
        case .squarify:
            "_app_icon_default".localized

        case .squarifyPro:
            "_app_icon_pro".localized
        }
    }

    var image: Image {
        Image(uiImage: UIImage(named: rawValue) ?? UIImage(systemName: "person") ?? UIImage())
    }
}

struct AppIconsPickerView: View {

    @State private var currentIconName: String? = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("_app_icons".localized)
                .font(.system(size: 30, weight: .black))
                .padding(.top)
            
            Spacer()

            ForEach(AppIcons.allCases) { icon in
                Button(action: { switchTo(iconName: icon.iconName) }) {
                    HStack(spacing: 10) {
                        icon.image
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                            .shadow(radius: 10)

                        Text(icon.title)
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
                            .scaleEffect(isCurrentIcon(icon.iconName) ? 1 : 0)
                            .opacity(isCurrentIcon(icon.iconName) ? 1 : 0)
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

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .leading)
        .presentationDetents([.fraction(1/2)])
        .presentationCornerRadius(50)
        .presentationDragIndicator(.visible)
        .onAppear {
            currentIconName = UIApplication.shared.alternateIconName
        }
    }

    func isCurrentIcon(_ iconName: String?) -> Bool {
        iconName == currentIconName
    }

    private func switchTo(iconName: String?) {
        guard
            UIApplication.shared.supportsAlternateIcons,
            UIApplication.shared.alternateIconName != iconName
        else { return }

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
