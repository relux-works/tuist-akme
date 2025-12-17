import ProjectDescription
import ProjectInfraPlugin

let project = Project(
    name: "macOSApp",
    targets: [
        .target(
            name: "AcmeMacApp",
            destinations: .macOS,
            product: .app,
            bundleId: "com.acme.mac-app",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "Auth", path: .relativeToRoot("Modules/Features/Auth")),
            ],
            settings: .regular
        ),
    ]
)

