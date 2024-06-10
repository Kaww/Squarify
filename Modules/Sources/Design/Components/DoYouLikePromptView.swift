import Foundation
import SwiftUI
import FeedbacksKit
import Utils
import Localization

public struct DoYouLikePromptView: View {

    private let notionSubmitService = NotionSubmitService(
        apiKey: notionAPIKey,
        databaseId: notionDatabaseID,
        notionVersion: notionVersion
    )

    private let onLike: () -> Void
    private let onDislike: () -> Void
    private let onClose: () -> Void

    public init(
        onLike: @escaping () -> Void,
        onDislike: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        self.onLike = onLike
        self.onDislike = onDislike
        self.onClose = onClose
    }

    public var body: some View {
        VStack {
            if showFeedbackForm {
                FeedbackForm(
                    service: notionSubmitService,
                    config: .init(title: "_how_can_we_improve".localized)
                )
            } else {
                promptView
                    .padding()
            }
        }
        .presentationDetents(currentDetents, selection: $currentDetent)
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
    }

    @State private var currentDetents: Set<PresentationDetent> = [PresentationDetent.fraction(1/3)]
    @State private var currentDetent = PresentationDetent.fraction(1/3)
    @State private var showFeedbackForm = false

    private var promptView: some View {
        VStack {
            Button(action: onClose) {
                Image(systemName: "multiply")
                    .font(.system(size: 22, weight: .medium))
            }
            .buttonStyle(.plain)
            .opacity(0.6)
            .frame(maxWidth: .infinity, alignment: .trailing)

            VStack(spacing: 8) {
                Text("_we_have_a_question_for_you".localized)
                    .font(.system(size: 16, weight: .medium))
                    .opacity(0.6)

                Text("_do_you_like_squarify".localized)
                    .font(.system(size: 28, weight: .semibold))
            }
            .fontDesign(.rounded)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack {
                noButton
                    .frame(maxWidth: .infinity)
                yesButton
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var yesButton: some View {
        Button(action: onLike) {
            VStack(spacing: 12) {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(size: 36, weight: .bold))
                Text("_yes".localized)
                    .font(.system(size: 22, weight: .medium))
            }
        }
        .tint(.green)
        .shadow(color: .green.opacity(0.5), radius: 20)
    }

    private var noButton: some View {
        Button(action: {
            onDislike()
            currentDetents.insert(.large)
            currentDetent = .large
            showFeedbackForm = true
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.2))
                currentDetents = [.large]
            }
        }) {
            VStack(spacing: 12) {
                Image(systemName: "hand.thumbsdown.fill")
                    .font(.system(size: 36, weight: .bold))
                Text("_no".localized)
                    .font(.system(size: 22, weight: .medium))
            }
        }
        .tint(.red)
        .shadow(color: .red.opacity(0.5), radius: 20)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            DoYouLikePromptView(
                onLike: {},
                onDislike: {},
                onClose: {}
            )
        }
}
