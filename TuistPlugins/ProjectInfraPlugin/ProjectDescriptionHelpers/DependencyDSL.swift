import ProjectDescription

/// A strongly-typed descriptor for an external dependency (SPM/binary).
///
/// This enables project-level allow-listing and layer-based validation (for example,
/// “Features may use Algorithms, but Alamofire is Core-only”).
public protocol ExternalDependencyDescriptor: Sendable {
    /// The external dependency name as referenced by Tuist (for example `"Alamofire"`).
    var name: String { get }

    /// The module layers that are allowed to link this dependency.
    var allowedLayers: Set<ModuleLayer> { get }
}

/// A dependency used by module manifests.
///
/// This wraps Tuist's `TargetDependency` and optionally carries metadata for external dependencies
/// so `ProjectFactory` can enforce architectural rules during manifest evaluation.
public struct Dependency {
    /// Underlying Tuist target dependency.
    public let target: TargetDependency

    /// Metadata used to validate external dependency usage against layer allow-lists.
    struct ExternalDependencyMetadata: Hashable, Sendable {
        /// External dependency name.
        let name: String

        /// Layers where this dependency is allowed.
        let allowedLayers: Set<ModuleLayer>
    }

    /// Metadata for external dependencies, when applicable.
    let externalDependency: ExternalDependencyMetadata?

    /// Internal initializer.
    private init(_ target: TargetDependency, externalDependency: ExternalDependencyMetadata?) {
        self.target = target
        self.externalDependency = externalDependency
    }

    /// Adds a dependency on another module's Interface target.
    public static func interface(_ module: ModuleID) -> Dependency {
        .init(.project(target: module.interfaceTarget, path: module.path), externalDependency: nil)
    }

    /// Adds a dependency on another module's Testing target.
    public static func testing(_ module: ModuleID) -> Dependency {
        .init(.project(target: module.testingTarget, path: module.path), externalDependency: nil)
    }

    /// Adds an external dependency by raw string (disallowed).
    @available(*, unavailable, message: "Don't use raw strings. Define a project-level allow-list in Tuist/ProjectDescriptionHelpers (e.g. ExternalDependency) and use Dep.external(.yourCase).")
    public static func external(_ name: String) -> Dependency {
        .init(.external(name: name), externalDependency: nil)
    }

    /// Adds an external dependency using a project-defined allow-list descriptor.
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
    /// Underlying Tuist dependencies to link.
    public let targets: [TargetDependency]

    /// Internal initializer.
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

    /// Adds an external dependency by raw string (disallowed).
    @available(*, unavailable, message: "Don't use raw strings. Define a project-level allow-list in Tuist/ProjectDescriptionHelpers (e.g. ExternalDependency) and use Dep.external(.yourCase).")
    public static func external(_ name: String) -> CompositionRootDependency {
        .init([.external(name: name)])
    }

    /// Adds an external dependency using a project-defined allow-list descriptor.
    public static func external(dependencyDescriptor dependency: some ExternalDependencyDescriptor) -> CompositionRootDependency {
        .init([.external(name: dependency.name)])
    }
}
