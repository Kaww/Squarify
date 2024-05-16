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
    
    public static func tryAsk() {
        guard let defaults = UserDefaults.squarify else {
            fatalError("Unable to init app user defaults container.")
        }

        let numberOfCompletedEdition = defaults.integer(forKey: AppStorageKeys.numberOfCompletedEditions)
        let lastPromptedVersion = defaults.string(forKey: AppStorageKeys.lastVersionPromptedForReview)

        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            fatalError("Expected to find a bundle version in the info dictionary.")
        }

        if numberOfCompletedEdition >= 2 && currentVersion != lastPromptedVersion {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                    UserDefaults.squarify?.set(currentVersion, forKey: AppStorageKeys.lastVersionPromptedForReview)
               }
            }
        }
    }
}
