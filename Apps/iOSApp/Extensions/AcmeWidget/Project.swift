import ProjectDescription
import ProjectInfraPlugin
import ProjectDescriptionHelpers

let developmentTeamId = Environment.developmentTeamId.getString(default: "")

let project = Project(
    name: "AcmeWidget",
    targets: [
        TargetFactory.makeExtension(
            name: "AcmeWidget",
            hostBundleId: AppIdentifiers.iOSApp.bundleId,
            destinations: .iOS,
            product: .appExtension,
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "Auth", path: .relativeToRoot("Modules/Features/Auth")),
            ],
            developmentTeamId: developmentTeamId
        ),
    ]
)

