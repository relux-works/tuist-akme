import ProjectDescription
import ProjectInfraPlugin

let target = TargetFactory.makeExtension(
    name: "AcmeWidget",
    destinations: .iOS,
    product: .appExtension,
    dependencies: [
        .project(target: "Auth", path: .relativeToRoot("Modules/Features/Auth")),
    ],
    resources: ["Resources/**"]
)

let project = Project(
    name: "AcmeWidget",
    targets: [target]
)

