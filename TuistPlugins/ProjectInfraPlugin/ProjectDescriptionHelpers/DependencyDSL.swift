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
