// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

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
    targets: [
        // MARK: - Base App
        .target(
            name: "BaseApp",
            dependencies: [
                "PhotoEditor",
                "PhotoPicker"
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
            dependencies: []
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
                "Utils"
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
            name: "Utils"
        ),
        .testTarget(
            name: "UtilsTests",
            dependencies: [
                "Utils"
            ]
        )
    ]
)
