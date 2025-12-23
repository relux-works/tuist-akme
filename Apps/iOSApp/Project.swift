import ProjectDescription
import ProjectInfraPlugin
import ProjectDescriptionHelpers

let developmentTeamId = Environment.developmentTeamId.getString(default: "")

let project = ProjectFactory.makeApp(
    projectName: "iOSApp",
    appName: "AcmeApp",
    bundleId: AppIdentifiers.iOSApp.bundleId,
    destinations: .iOS,
    deploymentTargets: .iOS("16.0"),
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    infoPlist: .extendingDefault(with: [
        "UILaunchScreen": [:],
    ]),
    dependencies: [
        .project(target: "AcmeWidget", path: .relativeToRoot("Apps/iOSApp/Extensions/AcmeWidget")),
        .project(target: "Auth", path: .relativeToRoot("Modules/Features/Auth")),
    ],
    developmentTeamId: developmentTeamId
)
