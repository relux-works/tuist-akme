@preconcurrency import ProjectDescription
@preconcurrency import ProjectInfraPlugin
@preconcurrency import ProjectDescriptionHelpers

let project = ProjectFactory.makeCompositionRoot(
    module: .widget,
    destinations: .iOS,
    product: .framework,
    dependencies: [
        .implementation(.feature(.auth)),
    ]
)
