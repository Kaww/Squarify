import Foundation
import StoreKit

public enum AppStoreReview {
    public static func recordCompletedEdition() {
        guard let defaults = UserDefaults.squarify else {
            fatalError("Unable to init app user defaults container.")
        }

        var numberOfCompletedEdition = defaults.integer(forKey: AppStorageKeys.numberOfCompletedEditions)
        numberOfCompletedEdition += 1
        defaults.set(numberOfCompletedEdition, forKey: AppStorageKeys.numberOfCompletedEditions)
    }

    public static func canAsk() -> Bool {
        guard let defaults = UserDefaults.squarify else {
            fatalError("Unable to init app user defaults container.")
        }

        let numberOfCompletedEdition = defaults.integer(forKey: AppStorageKeys.numberOfCompletedEditions)
        let lastPromptedVersion = defaults.string(forKey: AppStorageKeys.lastVersionPromptedForReview)

        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            fatalError("Expected to find a bundle version in the info dictionary.")
        }

        return numberOfCompletedEdition >= 2 && currentVersion != lastPromptedVersion
    }

    public static func recordAsked() {
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            fatalError("Expected to find a bundle version in the info dictionary.")
        }
        UserDefaults.squarify?.set(currentVersion, forKey: AppStorageKeys.lastVersionPromptedForReview)
    }

    public static func ask() {
        Task { @MainActor in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
                Self.recordAsked()
           }
        }
    }
}
