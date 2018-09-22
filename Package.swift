// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "sc19-swift-client",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/BlueSocket.git", from: "1.0.17")
    ],
    targets: [
        .target(name: "simple-client", dependencies: ["Socket"])
    ],
    swiftLanguageVersions: [.v4_2]
)