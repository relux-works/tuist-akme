import ProjectInfraPlugin

/// Canonical bundle identifiers shared across manifests.
///
/// Keeping bundle IDs in one place prevents drift between the host app and its extensions when:
/// - local bundle ID suffixes are enabled (`TUIST_BUNDLE_ID_SUFFIX`), or
/// - targets are split across multiple `Project.swift` files.
public enum AppIdentifiers {
    public enum iOSApp {
        public static let baseBundleId = "com.acme.app"
        public static var bundleId: String { ConfigurationHelper.applyEnvironmentSuffix(to: baseBundleId) }
    }

    public enum macOSApp {
        public static let baseBundleId = "com.acme.mac-app"
        public static var bundleId: String { ConfigurationHelper.applyEnvironmentSuffix(to: baseBundleId) }
    }
}

