// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum Dependency {
  static let feedbacksKit: Target.Dependency = .product(name: "FeedbacksKit", package: "FeedbacksKit")
  static let revenueCat: Target.Dependency = .product(name: "RevenueCat", package: "purchases-ios-spm")
  static let revenueCatUI: Target.Dependency = .product(name: "RevenueCatUI", package: "purchases-ios-spm")
  static let confettiSwiftUI: Target.Dependency = .product(name: "ConfettiSwiftUI", package: "ConfettiSwiftUI")
}

let package = Package(
  name: "Modules",
  defaultLocalization: "en",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "BaseApp", targets: ["BaseApp"]),
    .library(name: "Design", targets: ["Design"]),
    .library(name: "Localization", targets: ["Localization"]),
    .library(name: "PhotoEditor", targets: ["PhotoEditor"]),
    .library(name: "PhotoPicker", targets: ["PhotoPicker"]),
    .library(name: "Utils", targets: ["Utils"])
  ],
  dependencies: [
    .package(url: "https://github.com/Kaww/FeedbacksKit", from: "1.0.0"),
    .package(url: "https://github.com/RevenueCat/purchases-ios-spm", from: "4.43.0"),
    .package(url: "https://github.com/simibac/ConfettiSwiftUI", from: "1.0.0")
  ],
  targets: [
    // MARK: - Base App
    .target(
      name: "BaseApp",
      dependencies: [
        "Design",
        "PhotoEditor",
        "PhotoPicker",
        "Localization",
        "Utils",

        Dependency.confettiSwiftUI,
        Dependency.feedbacksKit,
        Dependency.revenueCat,
        Dependency.revenueCatUI
      ]
    ),
    .testTarget(
      name: "BaseAppTests",
      dependencies: [
        "BaseApp"
      ]
    ),

    // MARK: - Design
    .target(
      name: "Design",
      dependencies: [
        "Localization",
        "Utils",

        Dependency.feedbacksKit
      ]
    ),
    .testTarget(
      name: "DesignTests",
      dependencies: [
        "Design"
      ]
    ),

    // MARK: - Localization
    .target(
      name: "Localization",
      dependencies: []
    ),
    .testTarget(
      name: "LocalizationTests",
      dependencies: [
        "Localization"
      ]
    ),

    // MARK: - Photo Editor
    .target(
      name: "PhotoEditor",
      dependencies: [
        "Design",
        "Localization",
        "Utils",

        Dependency.confettiSwiftUI,
        Dependency.revenueCat,
        Dependency.revenueCatUI
      ]
    ),
    .testTarget(
      name: "PhotoEditorTests",
      dependencies: [
        "PhotoEditor",
      ]
    ),

    // MARK: - Photo Picker
    .target(
      name: "PhotoPicker",
      dependencies: [
        "Utils",
        "Design",
        "Localization"
      ]
    ),
    .testTarget(
      name: "PhotoPickerTests",
      dependencies: [
        "PhotoPicker"
      ]
    ),

    // MARK: - Utils
    .target(
      name: "Utils",
      dependencies: [
        Dependency.revenueCat
      ]
    ),
    .testTarget(
      name: "UtilsTests",
      dependencies: [
        "Utils"
      ]
    )
  ]
)
