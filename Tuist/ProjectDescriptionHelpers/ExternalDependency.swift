import ProjectInfraPlugin

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

    public var name: String { rawValue }

    public var allowedLayers: Set<ModuleLayer> {
        switch self {
        case .alamofire, .firebaseAnalytics, .keychainAccess:
            return [.core]
        case .algorithms, .kingfisher, .lottie, .snapKit:
            return [.core, .feature, .shared, .utility]
        }
    }
}

public extension Dependency {
    static func external(dependency: ExternalDependency) -> Dependency {
        Dependency.external(dependencyDescriptor: dependency)
    }
}
