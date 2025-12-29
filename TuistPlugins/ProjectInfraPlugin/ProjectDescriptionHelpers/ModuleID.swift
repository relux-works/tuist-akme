import ProjectDescription

/// High-level architectural layers used to group modules.
///
/// This is used for:
/// - folder layout (`ModuleID.path`)
/// - architecture validation (for example, external dependency allow-lists)
/// - bundle ID conventions
public enum ModuleLayer: String, Sendable {
    case core
    case compositionRoot
    case feature
    case shared
    case utility
    case app
}

/// A strongly-typed identifier for a module in the repository.
///
/// `ModuleID` is the central primitive used by the project DSL to derive:
/// - project paths (`Modules/<Layer>/<Name>`)
/// - target names (`<Name>Interface`, `<Name>`, `<Name>Testing`, `<Name>Tests`)
public struct ModuleID: Hashable, Sendable {
    /// Module layer (core/feature/shared/utility/etc).
    public let layer: ModuleLayer

    /// Module folder / product name (PascalCase, e.g. `Auth`).
    public let name: String

    /// Creates a module identifier.
    public init(_ layer: ModuleLayer, _ name: String) {
        self.layer = layer
        self.name = name
    }

    /// Path to the module's `Project.swift` folder.
    var path: Path {
        switch layer {
        case .app: return .relativeToRoot("Apps/\(name)")
        case .core: return .relativeToRoot("Modules/Core/\(name)")
        case .compositionRoot: return .relativeToRoot("Modules/CompositionRoots/\(name)")
        case .feature: return .relativeToRoot("Modules/Features/\(name)")
        case .shared: return .relativeToRoot("Modules/Shared/\(name)")
        case .utility: return .relativeToRoot("Modules/Utility/\(name)")
        }
    }

    /// Target name for the module's Interface target.
    var interfaceTarget: String { "\(name)Interface" }

    /// Target name for the module's implementation target.
    var implTarget: String { name }

    /// Target name for the module's Testing helpers target.
    var testingTarget: String { "\(name)Testing" }

    /// Target name for the module's unit tests target.
    var testsTarget: String { "\(name)Tests" }
}
