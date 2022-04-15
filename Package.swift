// swift-tools-version: 5.5

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Word Degree",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "Word Degree",
            targets: ["AppModule"],
            bundleIdentifier: "org.janiskirsteins.SimpleWordGame",
            teamIdentifier: "FN5YR78T7X",
            displayVersion: "1.0.1",
            bundleVersion: "4",
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
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
