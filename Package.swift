// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "PropertyObserver",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v4),
        .macCatalyst(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "PropertyObserver", targets: ["PropertyObserver"])
    ],
    targets: [
        .target(
            name: "PropertyObserver",
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        )
    ]
)
