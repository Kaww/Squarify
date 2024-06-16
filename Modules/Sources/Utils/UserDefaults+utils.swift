import Foundation

public struct AppStorageKeys {
    static let numberOfCompletedEditions = "NUMBER_OF_COMPLETED_EDITIONS"
    static let lastVersionPromptedForReview = "LAST_VERSION_PROMPTED_FOR_REVIEW"
    static let isUserPro = "IS_USER_PRO"
}

public extension UserDefaults {
    static let squarify = UserDefaults(suiteName: "SQUARIFY")
}
