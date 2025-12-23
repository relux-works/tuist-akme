import Foundation
import ProjectDescription

public enum ConfigurationHelper {
    /// Applies the environment-defined suffix (if any) to the provided base bundle identifier.
    ///
    /// Example:
    /// - Base: `com.acme.app`
    /// - `TUIST_BUNDLE_ID_SUFFIX=.ivan`
    /// - Result: `com.acme.app.ivan`
    public static func applyEnvironmentSuffix(to base: String) -> String {
        let suffix = Environment.bundleIdSuffix.getString(default: "")
        return applySuffix(suffix, to: base)
    }

    /// Applies a suffix to a bundle identifier.
    ///
    /// If `suffix` doesn't start with `.`, it gets normalized to `.<suffix>`.
    public static func applySuffix(_ suffix: String?, to base: String) -> String {
        let trimmed = (suffix ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return base }

        let normalized = trimmed.hasPrefix(".") ? trimmed : ".\(trimmed)"
        return "\(base)\(normalized)"
    }
}
