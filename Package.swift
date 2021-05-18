// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Xcore",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "Xcore", targets: ["Xcore"])
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.9.1")
    ],
    targets: [
        .target(name: "Xcore", dependencies: ["SDWebImage"], path: "Sources", exclude: ["Supporting Files/Info.plist"]),
        .testTarget(name: "UITests", dependencies: ["Xcore"], path: "UITests", exclude: ["Supporting Files/Info.plist"]),
        .testTarget(name: "UnitTests", dependencies: ["Xcore"], path: "UnitTests", exclude: ["Supporting Files/Info.plist"])
    ],
    swiftLanguageVersions: [.v5]
)
