@preconcurrency import ProjectDescription
@preconcurrency import ProjectInfraPlugin
@preconcurrency import ProjectDescriptionHelpers

let module = ModuleID(.feature, "Auth")

let project = ProjectFactory.makeFeature(
    module: module,
    destinations: Destinations.iOS.union(Destinations.macOS),
    product: .framework,
    dependencies: [
        .external(dependency: .algorithms),
        // Example: .interface(ModuleID(.core, "Networking"))
    ],
    testDependencies: [
        // Example: .testing(ModuleID(.core, "Networking"))
    ]
)
