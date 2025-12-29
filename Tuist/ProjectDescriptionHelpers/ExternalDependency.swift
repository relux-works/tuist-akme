import ProjectInfraPlugin

/// Project-wide allow-list of external dependencies.
///
/// Use this enum from module manifests via `Dependency.external(dependency:)` to avoid raw string
/// dependency names and to enable layer-based validation.
public enum ExternalDependency: String, CaseIterable, Sendable, ExternalDependencyDescriptor {
    // Infrastructure (Core Only)
    case alamofire = "Alamofire"
    case firebaseAnalytics = "FirebaseAnalytics"
    case keychainAccess = "KeychainAccess"

    // UI & Utilities (Allowed in Features)
    case algorithms = "Algorithms"
    case kingfisher = "Kingfisher"
    case lottie = "Lottie"
    case snapKit = "SnapKit"

    /// External dependency name as referenced by Tuist.
    public var name: String { rawValue }

    /// Layers where the dependency is allowed.
    public var allowedLayers: Set<ModuleLayer> {
        switch self {
        case .alamofire, .firebaseAnalytics, .keychainAccess:
            return [.core]
        case .algorithms, .kingfisher, .lottie, .snapKit:
            return [.core, .feature, .shared, .utility]
        }
    }
}

/// Convenience overloads for referencing project allow-listed external dependencies.
public extension Dependency {
    /// Adds a dependency on a project allow-listed external library.
    static func external(dependency: ExternalDependency) -> Dependency {
        Dependency.external(dependencyDescriptor: dependency)
    }
}
