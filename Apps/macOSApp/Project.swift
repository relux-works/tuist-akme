import ProjectDescription
import ProjectInfraPlugin
import ProjectDescriptionHelpers

let developmentTeamId = Environment.developmentTeamId.getString(default: "")

let project = ProjectFactory.makeHostApp(
    projectName: "macOSApp",
    appName: "AcmeMacApp",
    bundleId: AppIdentifiers.macOSApp.bundleId,
    destinations: .macOS,
    deploymentTargets: .macOS("13.0"),
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    compositionRoot: .app,
    capabilities: [
        .iCloudCloudKitContainer()
    ],
    developmentTeamId: developmentTeamId,
    automaticSigning: true
)
