// swift-tools-version: 5.5

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Wordlike",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "Wordlike",
            targets: ["AppModule"],
            bundleIdentifier: "org.janiskirsteins.SimpleWordGame",
            teamIdentifier: "FN5YR78T7X",
            displayVersion: "1.0.31",
            bundleVersion: "35",
            iconAssetName: "AppIcon",
            accentColorAssetName: "AccentColor",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/benlmyers/confetti-view", "1.1.2"..<"2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "ConfettiView", package: "confetti-view")
            ],
            path: ".",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
