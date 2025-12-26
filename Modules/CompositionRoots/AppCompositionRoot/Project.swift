@preconcurrency import ProjectDescription
@preconcurrency import ProjectInfraPlugin
@preconcurrency import ProjectDescriptionHelpers

let coreImplementations: [CompositionRootDependency] = CoreLayer.allCases
    .map { .implementation(.core($0)) }

let sharedImplementations: [CompositionRootDependency] = SharedLayer.allCases
    .map { .implementation(.shared($0)) }

let utilityImplementations: [CompositionRootDependency] = UtilityLayer.allCases
    .map { .implementation(.utility($0)) }

let featureImplementations: [CompositionRootDependency] = FeatureLayer.allCases
    .map { .implementation(.feature($0)) }

let project = ProjectFactory.makeCompositionRoot(
    module: .app,
    destinations: Destinations.iOS.union(Destinations.macOS),
    product: .framework,
    dependencies: coreImplementations
        + sharedImplementations
        + utilityImplementations
        + featureImplementations
)
