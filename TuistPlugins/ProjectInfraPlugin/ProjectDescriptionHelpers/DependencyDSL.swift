import ProjectDescription

public protocol ExternalDependencyDescriptor: Sendable {
    var name: String { get }
    var allowedLayers: Set<ModuleLayer> { get }
}

public struct Dependency {
    public let target: TargetDependency
    struct ExternalDependencyMetadata: Hashable, Sendable {
        let name: String
        let allowedLayers: Set<ModuleLayer>
    }

    let externalDependency: ExternalDependencyMetadata?

    private init(_ target: TargetDependency, externalDependency: ExternalDependencyMetadata?) {
        self.target = target
        self.externalDependency = externalDependency
    }

    public static func interface(_ module: ModuleID) -> Dependency {
        .init(.project(target: module.interfaceTarget, path: module.path), externalDependency: nil)
    }

    public static func testing(_ module: ModuleID) -> Dependency {
        .init(.project(target: module.testingTarget, path: module.path), externalDependency: nil)
    }

    @available(*, unavailable, message: "Don't use raw strings. Define a project-level allow-list in Tuist/ProjectDescriptionHelpers (e.g. ExternalDependency) and use Dep.external(.yourCase).")
    public static func external(_ name: String) -> Dependency {
        .init(.external(name: name), externalDependency: nil)
    }

    public static func external(dependencyDescriptor dependency: some ExternalDependencyDescriptor) -> Dependency {
        .init(
            .external(name: dependency.name),
            externalDependency: .init(name: dependency.name, allowedLayers: dependency.allowedLayers)
        )
    }
}

/// A dependency that is only intended to be used from composition roots.
///
/// Composition roots are the only place where it's acceptable to depend on other modules'
/// implementation targets directly.
public struct CompositionRootDependency: Sendable {
    public let targets: [TargetDependency]

    private init(_ targets: [TargetDependency]) {
        self.targets = targets
    }

    /// Links a module from a composition root.
    ///
    /// This adds both the Interface and Impl targets as direct dependencies so composition root
    /// code can import protocols from `*Interface` while still wiring concrete implementations.
    public static func module(_ module: ModuleID) -> CompositionRootDependency {
        .init(
            [
                .project(target: module.interfaceTarget, path: module.path),
                .project(target: module.implTarget, path: module.path),
            ]
        )
    }

    /// Links the concrete implementation target of a module.
    ///
    /// Composition roots usually need access to the module's Interface target as well.
    /// Use `module(_:)` when you want both targets as direct dependencies.
    public static func implementation(_ module: ModuleID) -> CompositionRootDependency {
        Self.module(module)
    }

    @available(*, unavailable, message: "Don't use raw strings. Define a project-level allow-list in Tuist/ProjectDescriptionHelpers (e.g. ExternalDependency) and use Dep.external(.yourCase).")
    public static func external(_ name: String) -> CompositionRootDependency {
        .init([.external(name: name)])
    }

    public static func external(dependencyDescriptor dependency: some ExternalDependencyDescriptor) -> CompositionRootDependency {
        .init([.external(name: dependency.name)])
    }
}
