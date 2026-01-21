@preconcurrency import ProjectDescription
@preconcurrency import ProjectInfraPlugin
@preconcurrency import ProjectDescriptionHelpers


let project = ProjectFactory.makeFeature(
    module: .feature(.auth, scope: .darwin),
    destinations: Destinations.iOS.union(Destinations.macOS),
    product: .framework,
    dependencies: [
        .external(dependency: .algorithms),
        .interface(.feature(.auth)),
        // Example: .interface(.core(.networking))
    ],
    testDependencies: [
        // Example: .testing(.core(.networking))
    ],
    additionalSettings: [
        : // Example "OTHER_LDFLAGS": ["-ObjC"],
    ],
    tags: [
        .owner(.identity),
        .area(.auth),
        .layer(.feature),
    ]
)
