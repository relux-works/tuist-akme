import ProjectDescription
import ProjectInfraPlugin

let appTarget = Target.target(
    name: "AcmeApp",
    destinations: .iOS,
    product: .app,
    bundleId: "com.acme.app",
    deploymentTargets: .iOS("16.0"),
    infoPlist: .extendingDefault(with: [
        "UILaunchScreen": [:],
    ]),
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    dependencies: [
        .project(target: "AcmeWidget", path: .relativeToRoot("Apps/iOSApp/Extensions/AcmeWidget")),
        .project(target: "Auth", path: .relativeToRoot("Modules/Features/Auth")),
    ],
    settings: .regular
)

let project = Project(
    name: "iOSApp",
    targets: [appTarget]
)
