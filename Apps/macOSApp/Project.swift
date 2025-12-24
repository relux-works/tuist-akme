import ProjectDescription
import ProjectInfraPlugin
import ProjectDescriptionHelpers

let developmentTeamId = Environment.developmentTeamId.getString(default: "")

let project = ProjectFactory.makeApp(
    projectName: "macOSApp",
    appName: "AcmeMacApp",
    bundleId: AppIdentifiers.macOSApp.bundleId,
    destinations: .macOS,
    deploymentTargets: .macOS("13.0"),
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    dependencies: [
        .project(target: "Auth", path: .relativeToRoot("Modules/Features/Auth")),
    ],
    developmentTeamId: developmentTeamId,
    automaticSigning: true
)
