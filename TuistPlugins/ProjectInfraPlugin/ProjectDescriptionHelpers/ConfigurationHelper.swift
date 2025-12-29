import Foundation
import ProjectDescription

/// Helper utilities for applying project-wide build conventions.
///
/// Currently this is focused on bundle identifier namespacing to avoid local signing conflicts.
public enum ConfigurationHelper {
    /// Applies the environment-defined suffix (if any) to the provided base bundle identifier.
    ///
    /// Example:
    /// - Base: `com.acme.app`
    /// - `TUIST_BUNDLE_ID_SUFFIX=.ivan`
    /// - Result: `com.acme.ivan.app`
    public static func applyEnvironmentSuffix(to base: String) -> String {
        let suffix = Environment.bundleIdSuffix.getString(default: "")
        return applySuffix(suffix, to: base)
    }

    /// Same as `applyEnvironmentSuffix(to:)`, but allows choosing where the namespace components
    /// get inserted.
    ///
    /// Example (App Groups):
    /// - Base: `group.com.acme.shared`, Suffix: `.ivan`, Insert after 3 → `group.com.acme.ivan.shared`
    public static func applyEnvironmentSuffix(to base: String, afterComponents: Int) -> String {
        let suffix = Environment.bundleIdSuffix.getString(default: "")
        return applySuffix(suffix, to: base, afterComponents: afterComponents)
    }

    /// Applies a suffix to a bundle identifier.
    ///
    /// The suffix is treated as a *namespace component* and gets inserted after the first two
    /// bundle ID components (e.g. `com.acme`), which preserves common wildcard App IDs like
    /// `com.acme.*`.
    ///
    /// Examples:
    /// - Base: `com.acme.app`, Suffix: `.ivan` → `com.acme.ivan.app`
    /// - Base: `com.acme.feature.Auth`, Suffix: `ivan` → `com.acme.ivan.feature.Auth`
    public static func applySuffix(_ suffix: String?, to base: String) -> String {
        applySuffix(suffix, to: base, afterComponents: 2)
    }

    /// Applies a suffix to an identifier by inserting its components after the specified number
    /// of dot-separated components.
    ///
    /// Use this for non-bundle-ID identifiers that still follow a reverse-DNS convention (e.g.
    /// `group.com.company.*`, `iCloud.com.company.*`).
    public static func applySuffix(_ suffix: String?, to base: String, afterComponents: Int) -> String {
        let trimmed = (suffix ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return base }

        let namespaceComponents = trimmed
            .split(separator: ".")
            .map(String.init)
            .filter { !$0.isEmpty }

        guard !namespaceComponents.isEmpty else { return base }

        var components = base.split(separator: ".").map(String.init)
        let insertionIndex = min(max(afterComponents, 0), components.count)
        if insertionIndex + namespaceComponents.count <= components.count {
            let existing = components[insertionIndex ..< insertionIndex + namespaceComponents.count]
            if Array(existing) == namespaceComponents {
                return base
            }
        }
        components.insert(contentsOf: namespaceComponents, at: insertionIndex)
        return components.joined(separator: ".")
    }
}
