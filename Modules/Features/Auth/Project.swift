@preconcurrency import ProjectDescription
@preconcurrency import ProjectInfraPlugin

let module = ModuleID(.feature, "Auth")

let project = ProjectFactory.makeFeature(
    module: module,
    destinations: Destinations.iOS.union(Destinations.macOS),
    product: .framework,
    dependencies: [
        .external("Kingfisher"),
        // Example: .interface(ModuleID(.core, "Networking"))
    ],
    testDependencies: [
        // Example: .testing(ModuleID(.core, "Networking"))
    ]
)
