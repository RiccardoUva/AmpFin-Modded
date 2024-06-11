// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AmpFinKit",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .tvOS(.v17),
    ],
    products: [
        .library(name: "AFBase", targets: ["AFBase", "AFExtension"]),
        .library(name: "AFOffline", targets: ["AFOffline"]),
        .library(name: "AFPlayback", targets: ["AFPlayback"]),
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", from: .init(4, 0, 0)),
        .package(url: "https://github.com/sindresorhus/Defaults.git", from: .init(8, 2, 0)),
    ],
    targets: [
        .target(name: "AFBase", dependencies: [
            .byName(name: "Defaults"),
            .byName(name: "Starscream"),
        ]),
        .target(name: "AFExtension", dependencies: [
            .byName(name: "AFBase"),
            .byName(name: "AFOffline", condition: .when(platforms: [.iOS, .watchOS, .visionOS, .macOS]))
        ]),
        
        .target(name: "AFOffline", dependencies: [.byName(name: "AFBase")]),
        
        .target(
            name: "AFPlayback",
            dependencies: [
                .byName(name: "AFBase"),
                .byName(name: "AFExtension"),
                .byName(name: "AFOffline", condition: .when(platforms: [.iOS, .watchOS, .visionOS, .macOS]))],
            resources: [.process("RemoteAudioEndpoint/silence.wav")]),
    ]
)
