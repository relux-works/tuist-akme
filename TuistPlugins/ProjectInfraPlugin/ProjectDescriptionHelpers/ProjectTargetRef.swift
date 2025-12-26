import ProjectDescription

/// A strongly-typed reference to a target living in another Tuist project.
///
/// This is useful for host apps embedding extensions (widgets, notification service extensions, etc.)
/// without scattering raw target names and paths across manifests.
public struct ProjectTargetRef: Hashable, Sendable {
    public let target: String
    public let path: Path

    public init(target: String, path: Path) {
        self.target = target
        self.path = path
    }

    public var dependency: TargetDependency {
        .project(target: target, path: path)
    }
}

