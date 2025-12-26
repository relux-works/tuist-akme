import ProjectDescription

public enum ModuleLayer: String, Sendable {
    case core
    case compositionRoot
    case feature
    case shared
    case utility
    case app
}

public struct ModuleID: Hashable, Sendable {
    public let layer: ModuleLayer
    public let name: String

    public init(_ layer: ModuleLayer, _ name: String) {
        self.layer = layer
        self.name = name
    }

    public var path: Path {
        switch layer {
        case .app: return .relativeToRoot("Apps/\(name)")
        case .core: return .relativeToRoot("Modules/Core/\(name)")
        case .compositionRoot: return .relativeToRoot("Modules/CompositionRoots/\(name)")
        case .feature: return .relativeToRoot("Modules/Features/\(name)")
        case .shared: return .relativeToRoot("Modules/Shared/\(name)")
        case .utility: return .relativeToRoot("Modules/Utility/\(name)")
        }
    }

    public var interfaceTarget: String { "\(name)Interface" }
    public var implTarget: String { name }
    public var testingTarget: String { "\(name)Testing" }
    public var testsTarget: String { "\(name)Tests" }
}
