import ProjectDescription

/// A strongly-typed reference to a target living in another Tuist project.
///
/// This is useful for host apps embedding extensions (widgets, notification service extensions, etc.)
/// without scattering raw target names and paths across manifests.
public struct ProjectTargetRef: Hashable, Sendable {
    /// Target name in the referenced project.
    public let target: String

    /// Filesystem path to the referenced project.
    public let path: Path

    /// Creates a reference to a target in another project.
    public init(target: String, path: Path) {
        self.target = target
        self.path = path
    }

    /// Converts the reference into a Tuist `TargetDependency`.
    public var dependency: TargetDependency {
        .project(target: target, path: path)
    }
}
