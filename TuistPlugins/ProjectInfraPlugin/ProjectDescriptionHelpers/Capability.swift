import ProjectDescription

/// A typed representation of an Xcode “capability” (primarily entitlements).
///
/// Capabilities are declared in app / app extension manifests and are translated into
/// `.entitlements` via `EntitlementsFactory`.
public struct Capability: Hashable, Sendable {
    /// Controls whether a custom identifier should be namespaced with the local environment suffix.
    ///
    /// This is primarily used to avoid signing collisions when multiple developers build the same
    /// project on device (for example by inserting `.ivan` into identifiers derived from
    /// reverse-DNS strings).
    public enum Namespacing: Hashable, Sendable {
        /// Do not modify the provided identifier.
        case none

        /// Apply `TUIST_BUNDLE_ID_SUFFIX` using `ConfigurationHelper`.
        case environmentSuffix
    }

    /// iCloud services used by the target.
    ///
    /// Mirrors the service checkboxes shown by Xcode under the iCloud capability.
    public struct ICloudServices: OptionSet, Hashable, Sendable {
        /// Bitmask raw value backing the option set.
        ///
        /// Prefer using the predefined options (`.keyValueStorage`, `.documents`, `.cloudKit`).
        public let rawValue: Int

        /// Creates a service set from a raw bitmask.
        ///
        /// Prefer using the predefined options (`.keyValueStorage`, `.documents`, `.cloudKit`).
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// iCloud key-value storage (`com.apple.developer.ubiquity-kvstore-identifier`).
        public static let keyValueStorage = ICloudServices(rawValue: 1 << 0)

        /// iCloud Documents (`com.apple.developer.ubiquity-container-identifiers`).
        public static let documents = ICloudServices(rawValue: 1 << 1)

        /// CloudKit (`com.apple.developer.icloud-container-identifiers`).
        public static let cloudKit = ICloudServices(rawValue: 1 << 2)
    }

    /// A capability identifier that can be derived from the host bundle ID or provided explicitly.
    ///
    /// Many capabilities use a “default” identifier convention (for example `group.<bundle id>`
    /// for App Groups or `iCloud.<bundle id>` for iCloud containers).
    public enum Identifier: Hashable, Sendable {
        /// Uses the capability’s default identifier derived from the host bundle ID.
        case `default`

        /// Uses an explicit identifier.
        ///
        /// The `namespacing` parameter controls whether the local environment suffix is applied; default behavior applies env suffix.
        case custom(id: String, namespacing: Namespacing = .environmentSuffix)
    }

    /// App Group identifiers used by the App Groups capability.
    ///
    /// App Group identifiers must start with `group.`.
    public enum AppGroupIdentifier: Hashable, Sendable {
        /// An explicitly provided identifier value.
        ///
        /// Use `prependingGroupPrefix(_:)` to build an App Group identifier from a reverse-DNS
        /// string without manually typing `group.`.
        public struct Value: Hashable, Sendable, ExpressibleByStringLiteral {
            /// Underlying identifier string.
            public let rawValue: String

            /// Creates a value from a raw identifier string.
            ///
            /// Any leading/trailing whitespace is trimmed.
            public init(_ rawValue: String) {
                self.rawValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            /// Creates a value from a string literal.
            ///
            /// Any leading/trailing whitespace is trimmed.
            public init(stringLiteral value: String) {
                self.init(value)
            }

            /// Creates an App Group identifier by prepending the `group.` prefix when missing.
            ///
            /// Example:
            /// - Input: `com.acme.shared` → Output: `group.com.acme.shared`
            public static func prependingGroupPrefix(_ value: String) -> Self {
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.hasPrefix("group.") else { return Self(trimmed) }
                return Self("group.\(trimmed)")
            }
        }

        /// Uses the capability’s default identifier derived from the host bundle ID.
        case `default`

        /// Uses an explicit identifier.
        ///
        /// - Important: The value must start with `group.`. Prefer using
        ///   `Value.prependingGroupPrefix(_:)`.
        ///
        /// The `namespacing` parameter controls whether the local environment suffix is applied; default behavior applies env suffix.
        case custom(id: Value, namespacing: Namespacing = .environmentSuffix)

        /// Converts the App Group identifier into a generic capability identifier.
        var identifier: Identifier {
            switch self {
            case .default:
                return .default
            case let .custom(id: id, namespacing: namespacing):
                return .custom(id: id.rawValue, namespacing: namespacing)
            }
        }
    }

    /// Internal representation used by `EntitlementsFactory` for entitlement generation.
    enum Kind: Hashable, Sendable {
        case iCloud(services: ICloudServices, containers: [Identifier], keyValueStoreIdentifier: Identifier)
        case keychainSharing(group: Identifier)
        case appGroups(group: Identifier)
        case iCloudUbiquityContainer(container: Identifier)
        case iCloudCloudKitContainer(container: Identifier)
        case iCloudKeyValueStore(id: Identifier)
        case applePayMerchant(id: Identifier)
        case walletPassType(id: Identifier)
        case associatedDomains(domains: [String])
    }

    /// Backing payload for the capability.
    let kind: Kind

    /// Creates a capability from an internal payload.
    ///
    /// Prefer using the static factory methods (e.g. `.appGroups()`, `.iCloud(services:)`).
    private init(_ kind: Kind) {
        self.kind = kind
    }

    /// Keychain Sharing (`keychain-access-groups`).
    ///
    /// Default: `$(AppIdentifierPrefix)<host bundle id>`
    public static func keychainSharing(group: Identifier = .default) -> Self {
        .init(.keychainSharing(group: group))
    }

    /// iCloud capability (services + containers).
    ///
    /// This is the high-level, “Xcode-like” API. It expands to the underlying entitlements:
    /// - `com.apple.developer.icloud-services` for `.documents` and `.cloudKit`
    /// - `com.apple.developer.ubiquity-container-identifiers` for `.documents`
    /// - `com.apple.developer.icloud-container-identifiers` for `.cloudKit`
    /// - `com.apple.developer.ubiquity-kvstore-identifier` for `.keyValueStorage`
    ///
    /// - Important: Not tested.
    ///
    /// Defaults:
    /// - Containers: `[iCloud.<host bundle id>]`
    /// - Key-value store identifier: `$(AppIdentifierPrefix)<host bundle id>`
    public static func iCloud(
        services: ICloudServices,
        containers: [Identifier] = [.default],
        keyValueStoreIdentifier: Identifier = .default
    ) -> Self {
        .init(.iCloud(services: services, containers: containers, keyValueStoreIdentifier: keyValueStoreIdentifier))
    }

    /// App Groups (`com.apple.security.application-groups`).
    ///
    /// Default: `group.<host bundle id>`
    public static func appGroups(group: AppGroupIdentifier = .default) -> Self {
        .init(.appGroups(group: group.identifier))
    }

    /// iCloud Documents / Ubiquity container identifiers (`com.apple.developer.ubiquity-container-identifiers`).
    ///
    /// - Important: Not tested
    ///
    /// Default: `iCloud.<host bundle id>`
    public static func iCloudUbiquityContainer(container: Identifier = .default) -> Self {
        .init(.iCloudUbiquityContainer(container: container))
    }

    /// CloudKit container identifiers (`com.apple.developer.icloud-container-identifiers`).
    ///
    /// - Important: Not tested
    ///
    /// Default: `iCloud.<host bundle id>`
    public static func iCloudCloudKitContainer(container: Identifier = .default) -> Self {
        .init(.iCloudCloudKitContainer(container: container))
    }

    /// iCloud key-value store identifier (`com.apple.developer.ubiquity-kvstore-identifier`).
    ///
    /// Default: `$(AppIdentifierPrefix)<host bundle id>`
    public static func iCloudKeyValueStore(id: Identifier = .default) -> Self {
        .init(.iCloudKeyValueStore(id: id))
    }

    /// Apple Pay merchant IDs (`com.apple.developer.in-app-payments`).
    ///
    /// - Important: Not tested.
    ///
    /// Default: `merchant.<host bundle id>`
    public static func applePayMerchant(id: Identifier = .default) -> Self {
        .init(.applePayMerchant(id: id))
    }

    /// Wallet pass type IDs (`com.apple.developer.pass-type-identifiers`).
    ///
    /// - Important: Not tested
    ///
    /// Default: `pass.<host bundle id>`
    public static func walletPassType(id: Identifier = .default) -> Self {
        .init(.walletPassType(id: id))
    }

    /// Associated domains (`com.apple.developer.associated-domains`).
    public static func associatedDomains(_ domains: [String]) -> Self {
        .init(.associatedDomains(domains: domains))
    }
}
