// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ProjectInfraPlugin",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "ProjectInfraPlugin", targets: ["ProjectInfraPlugin"]),
    ],
    targets: [
        .target(
            name: "ProjectInfraPlugin",
            dependencies: [
                .target(name: "ProjectDescription"),
            ],
            path: "ProjectDescriptionHelpers"
        ),
        .binaryTarget(
            name: "ProjectDescription",
            url: "https://github.com/tuist/tuist/releases/download/4.116.2/ProjectDescription.xcframework.zip",
            checksum: "c6138ed4ed057a3bf10a9d856e1d3d6558e808afb9477a82ed08f00343e94a81"
        ),
    ]
)
