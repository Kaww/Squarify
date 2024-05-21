import SwiftUI
import Design
import FeedbacksKit
import Utils

struct SettingsView: View {

    private let notionSubmitService = NotionSubmitService(
        apiKey: notionAPIKey,
        databaseId: notionDatabaseID,
        notionVersion: notionVersion
    )

    @State private var showFeedbackForm = false

    var body: some View {
        List {
            feedbackFormView
            loveSquarifyView
        }
        .navigationTitle(Text("_settings".localized))
        .navigationBarTitleDisplayMode(.inline)
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

    private var loveSquarifyView: some View {
        Section {
            Button(action: requestReviewManually) {
                HStack {
                    itemImage(Image(systemName: "heart.fill"), color: .pinkLove)
                    Text("_write_a_review".localized)
                        .foregroundColor(.neutral0)
                }
            }
        } header: {
            Text("_you_love_squarify".localized)
        }
    }

    private func requestReviewManually() {
        let appStoreID = appStoreID
        if let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review") {
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
