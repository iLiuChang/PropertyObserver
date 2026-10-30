// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "PropertyObserver",
    platforms: [.iOS(.v11)],
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
