// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WebMConverter",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "WebMConverter",
            path: "Sources/WebMConverter"
        )
    ]
)
