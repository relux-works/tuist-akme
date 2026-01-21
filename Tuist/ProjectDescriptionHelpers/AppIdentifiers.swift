import ProjectDescription
import ProjectInfraPlugin

/// Canonical bundle identifiers shared across manifests.
///
/// Keeping bundle IDs in one place prevents drift between the host app and its extensions when:
/// - local bundle ID suffixes are enabled (`TUIST_BUNDLE_ID_SUFFIX`), or
/// - targets are split across multiple `Project.swift` files.
public enum AppIdentifiers {
    /// Canonical reverse-DNS root used to derive bundle IDs across platforms.
    public static var coreRoot: String {
        Environment.coreRoot.getString(default: "com.acme.akmeapp")
    }

    /// Explicit shared identifier root used for cross-platform capability identifiers (opt-in).
    public static var sharedRoot: String {
        Environment.sharedRoot.getString(default: "\(coreRoot).shared")
    }

    /// iOS host app bundle identifier.
    public enum iOSApp {
        /// Base bundle identifier without any local environment suffix.
        public static var baseBundleId: String { "\(AppIdentifiers.coreRoot).app.ios" }

        /// Bundle identifier with any configured local environment suffix applied.
        public static var bundleId: String { ConfigurationHelper.applyEnvironmentSuffix(to: baseBundleId) }

        /// Companion WatchKit app bundle identifier (when using a companion iOS app).
        public static var watchKitAppBundleId: String { "\(bundleId).watchkitapp" }

        /// Companion WatchKit extension bundle identifier (when using a companion iOS app).
        public static var watchKitExtensionBundleId: String { "\(bundleId).watchkitextension" }

        /// App Clip bundle identifier.
        public static var appClipBundleId: String { "\(bundleId).clip" }
    }

    /// macOS host app bundle identifier.
    public enum macOSApp {
        /// Base bundle identifier without any local environment suffix.
        public static var baseBundleId: String { "\(AppIdentifiers.coreRoot).app.macos" }

        /// Bundle identifier with any configured local environment suffix applied.
        public static var bundleId: String { ConfigurationHelper.applyEnvironmentSuffix(to: baseBundleId) }
    }
}
