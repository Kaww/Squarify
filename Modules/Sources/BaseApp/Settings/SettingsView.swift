import SwiftUI
import Design
import FeedbacksKit
import Utils
import RevenueCat
import RevenueCatUI
import ConfettiSwiftUI

struct SettingsView: View {

  @Environment(ProPlanService.self) private var proPlanService

  private let notionSubmitService = NotionSubmitService(
    apiKey: notionAPIKey,
    databaseId: notionDatabaseID,
    notionVersion: notionVersion
  )

  @State private var showFeedbackForm = false
  @State private var showActiveProPlan = false
  @State private var showPaywall = false
  @State private var showAppIconsPicker = false
  @State private var confettiCannonTrigger: Int = 0

  var body: some View {
    List {
      feedbackFormView
      loveSquarifyView
      proView
    }
    .navigationTitle(Text("_settings".localized))
    .navigationBarTitleDisplayMode(.inline)
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

  private func itemImage(_ image: Image, color: Color? = nil) -> some View {
    RoundedRectangle(cornerRadius: 8, style: .continuous)
      .foregroundColor(color ?? .risdBlue)
      .frame(width: 28, height: 28)
      .overlay(
        image
          .foregroundColor(.white)
      )
  }

  // MARK: FEEDBACK FORM

  private var feedbackFormView: some View {
    Section {
      Button {
        showFeedbackForm = true
      } label: {
        HStack {
          itemImage(
            Image(systemName: "quote.bubble.fill"),
            color: .risdBlueLighter
          )
          Text("_contact_developer".localized)
            .foregroundColor(.neutral0)
        }
      }
      .sheet(isPresented: $showFeedbackForm) {
        FeedbackForm(service: notionSubmitService)
      }
    } header: {
      Text("_a_question".localized)
    }
  }

  // MARK: APP STORE REVIEW

  private var appStoreURL: URL {
    URL(string: "https://apps.apple.com/app/id\(appStoreID)")!
  }

  private var appStoreReviewURL: URL {
    URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review")!
  }

  private var loveSquarifyView: some View {
    Section {
      Button(action: { open(appStoreReviewURL) }) {
        HStack {
          itemImage(Image(systemName: "heart.fill"), color: .pinkLove)
          Text("_write_a_review".localized)
            .foregroundColor(.neutral0)
        }
      }

      HStack {
        ShareLink(item: appStoreURL) {
          HStack {
            itemImage(Image(systemName: "square.and.arrow.up"), color: .pinkLove)
              .bold()
            Text("_share_app".localized)
              .foregroundColor(.neutral0)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }

        Rectangle()
          .frame(width: 50)
          .opacity(0.001)
          .onLongPressGesture { open(appStoreURL) }
      }
    } header: {
      Text("_you_love_squarify".localized)
    }
  }

  private func open(_ url: URL) {
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }

  var isPro: Bool {
    proPlanService.currentStatus == .pro
  }

  private var proView: some View {
    Section(
      content: {
        if !isPro {
          Button(action: { showPaywall = true }) {
            HStack {
              itemImage(Image(systemName: "dollarsign"), color: .yellow)
              Text("_buy_squarify_pro".localized)
                .foregroundColor(.neutral0)
            }
          }
        }

        Button(action: { showAppIconsPicker = true }) {
          HStack {
            itemImage(Image(systemName: "app.badge.fill"), color: .black)
            Text("_app_icons".localized)
              .foregroundColor(.neutral0)
          }
        }
        .popover(isPresented: $showAppIconsPicker) { AppIconsPickerView() }
      },
      header: {
        Text("_squarify_pro".localized)
      },
      footer: {
        if isPro {
          Group {
            Text("_thanks_for_pro_plan".localized)
            + Text("\n")
            + Text("_your_pro_plan_benefits".localized)
              .underline()
              .foregroundColor(.blue)
          }
          .frame(maxWidth: .infinity)
          .multilineTextAlignment(.center)
          .onTapGesture { showActiveProPlan = true }
          .popover(isPresented: $showActiveProPlan) { activeProPlanBenefitsView }
        }
      }
    )
  }

  private var activeProPlanBenefitsView: some View {
    VStack(alignment: .leading) {
      Text("_your_pro_plan_benefits".localized)
        .font(.system(size: 30, weight: .black))
        .padding(.top)
      Spacer()
      Text("✅ " + "_pro_benefit_blur_border".localized)
        .font(.system(size: 16, weight: .medium, design: .rounded))
      Spacer()
      Text("✅ " + "_pro_benefit_aspect_ratios".localized)
        .font(.system(size: 16, weight: .medium, design: .rounded))
      Spacer()
      Text("✅ " + "_pro_benefit_app_icons".localized)
        .font(.system(size: 16, weight: .medium, design: .rounded))
      Spacer()
      Text("✅ " + "_pro_benefit_future_features".localized)
        .font(.system(size: 16, weight: .medium, design: .rounded))
      Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 20)
    .padding(.vertical)
    .presentationDetents([.fraction(1.0/3.0)])
    .presentationCornerRadius(50)
    .presentationDragIndicator(.visible)
  }
}

#Preview {
  NavigationStack {
    SettingsView()
  }
  .environment(ProPlanService())
}
