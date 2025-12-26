import ProjectDescription
import ProjectInfraPlugin
import ProjectDescriptionHelpers

let developmentTeamId = Environment.developmentTeamId.getString(default: "")

let project = ProjectFactory.makeHostApp(
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
    compositionRoot: .app,
    embeddedExtensions: [
        AppProjects.iOS.acmeWidget,
    ],
    capabilities: .iOSPlusAppex,
    developmentTeamId: developmentTeamId
)
