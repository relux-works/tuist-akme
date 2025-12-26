import Foundation

public enum BundleID {
    public enum Kind: String, Sendable {
        case interface
        case impl
        case testing
        case tests
    }

    public static func module(_ module: ModuleID, kind: Kind) -> String {
        let base = "com.acme.\(module.layer.rawValue).\(module.name)"
        let namespaced = ConfigurationHelper.applyEnvironmentSuffix(to: base)
        return "\(namespaced).\(kind.rawValue)"
    }
}
