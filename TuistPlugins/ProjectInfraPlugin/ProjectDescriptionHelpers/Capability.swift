import ProjectDescription

public struct Capability: Hashable, Sendable {
    public enum Namespacing: Hashable, Sendable {
        case none
        case environmentSuffix
    }

    public enum Identifier: Hashable, Sendable {
        case `default`
        case custom(id: String, namespacing: Namespacing = .environmentSuffix)
    }

    enum Kind: Hashable, Sendable {
        case keychainSharing(group: Identifier)
        case appGroups(group: Identifier)
        case iCloudUbiquityContainer(container: Identifier)
        case iCloudCloudKitContainer(container: Identifier)
        case iCloudKeyValueStore(id: Identifier)
        case applePayMerchant(id: Identifier)
        case walletPassType(id: Identifier)
        case associatedDomains(domains: [String])
    }

    let kind: Kind

    private init(_ kind: Kind) {
        self.kind = kind
    }

    /// Keychain Sharing (`keychain-access-groups`).
    ///
    /// Default: `$(AppIdentifierPrefix)<host bundle id>`
    public static func keychainSharing(group: Identifier = .default) -> Self {
        .init(.keychainSharing(group: group))
    }

    /// App Groups (`com.apple.security.application-groups`).
    ///
    /// Default: `group.<host bundle id>`
    public static func appGroups(group: Identifier = .default) -> Self {
        .init(.appGroups(group: group))
    }

    /// iCloud Documents / Ubiquity container identifiers (`com.apple.developer.ubiquity-container-identifiers`).
    ///
    /// Default: `iCloud.<host bundle id>`
    public static func iCloudUbiquityContainer(container: Identifier = .default) -> Self {
        .init(.iCloudUbiquityContainer(container: container))
    }

    /// CloudKit container identifiers (`com.apple.developer.icloud-container-identifiers`).
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
    /// Default: `merchant.<host bundle id>`
    public static func applePayMerchant(id: Identifier = .default) -> Self {
        .init(.applePayMerchant(id: id))
    }

    /// Wallet pass type IDs (`com.apple.developer.pass-type-identifiers`).
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
