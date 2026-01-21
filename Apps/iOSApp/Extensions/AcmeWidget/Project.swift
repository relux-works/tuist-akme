import ProjectDescription
import ProjectInfraPlugin
import ProjectDescriptionHelpers

let developmentTeamId = Environment.developmentTeamId.getString(default: "")

let project = ProjectFactory.makeAppExtensionProject(
    name: "AcmeWidget",
    hostBundleId: AppIdentifiers.iOSApp.bundleId,
    bundleIdType: "widget",
    destinations: .iOS,
    product: .appExtension,
    compositionRoot: .widget,
    capabilities: .iOSPlusAppex,
    resources: ["Resources/**"],
    developmentTeamId: developmentTeamId
)
