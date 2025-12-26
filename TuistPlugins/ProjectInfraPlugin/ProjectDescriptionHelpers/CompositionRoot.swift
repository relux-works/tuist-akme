import ProjectDescription

/// A strongly-typed reference to a composition root module.
///
/// Composition roots are special modules that are allowed to depend on other modules'
/// **implementation** targets directly. Host apps and app extensions should link to a composition
/// root rather than linking feature implementations individually.
///
/// Project-specific composition roots (for example `.app`, `.widget`) should be defined as
/// extensions in `Tuist/ProjectDescriptionHelpers` to keep the plugin project-agnostic.
public struct CompositionRoot: Hashable, Sendable {
    public let id: ModuleID

    public init(_ id: ModuleID) {
        guard id.name.hasSuffix("CompositionRoot") else {
            fatalError("Expected a composition root module (name must end with 'CompositionRoot'), got: \(id.name)")
        }
        self.id = id
    }

    public var dependency: TargetDependency {
        .project(target: id.implTarget, path: id.path)
    }
}

