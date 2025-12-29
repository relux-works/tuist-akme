import ProjectDescription

/// Builds `.entitlements` values from a set of `Capability` declarations.
///
/// This is the source of truth for what gets written to `Derived/Entitlements/*.entitlements`
/// (and what ends up in the code signature) for host apps and app extensions.
public enum EntitlementsFactory {
    /// Builds an `Entitlements` value for the given host bundle ID and capabilities.
    ///
    /// Returns `nil` when `capabilities` don't produce any entitlements.
    public static func make(hostBundleId: String, capabilities: [Capability]) -> Entitlements? {
        let dictionary = makeDictionary(hostBundleId: hostBundleId, capabilities: capabilities)
        guard !dictionary.isEmpty else { return nil }
        return .dictionary(dictionary)
    }

    /// Builds a raw entitlement dictionary suitable for `Entitlements.dictionary(_:)`.
    ///
    /// - Parameter hostBundleId: The host application's bundle identifier (already namespaced if
    ///   `TUIST_BUNDLE_ID_SUFFIX` is used).
    /// - Parameter capabilities: Capability declarations to convert into entitlement keys/values.
    public static func makeDictionary(hostBundleId: String, capabilities: [Capability]) -> [String: Plist.Value] {
        var keychainAccessGroups: Set<String> = []
        var applicationGroups: Set<String> = []
        var ubiquityContainerIdentifiers: [String] = []
        var cloudKitContainerIdentifiers: [String] = []
        var iCloudServices: Set<String> = []
        var ubiquityKVStoreIdentifier: String?
        var merchantIdentifiers: Set<String> = []
        var passTypeIdentifiers: Set<String> = []
        var associatedDomains: Set<String> = []

        for capability in capabilities {
            switch capability.kind {
            case let .iCloud(services, containers, keyValueStoreIdentifier):
                let resolvedContainers = containers.isEmpty ? [.default] : containers

                if services.contains(.documents) {
                    iCloudServices.insert("CloudDocuments")
                    ubiquityContainerIdentifiers.append(contentsOf: resolvedContainers.map { resolveICloudContainer($0, hostBundleId: hostBundleId) })
                }

                if services.contains(.cloudKit) {
                    iCloudServices.insert("CloudKit")
                    cloudKitContainerIdentifiers.append(contentsOf: resolvedContainers.map { resolveICloudContainer($0, hostBundleId: hostBundleId) })
                }

                if services.contains(.keyValueStorage) {
                    ubiquityKVStoreIdentifier = resolvePrefixedIdentifier(keyValueStoreIdentifier, defaultUnprefixed: hostBundleId, afterComponents: 2)
                }

            case let .keychainSharing(group):
                keychainAccessGroups.insert(resolveKeychainAccessGroup(group, hostBundleId: hostBundleId))

            case let .appGroups(group):
                applicationGroups.insert(resolveAppGroup(group, hostBundleId: hostBundleId))

            case let .iCloudUbiquityContainer(container):
                iCloudServices.insert("CloudDocuments")
                ubiquityContainerIdentifiers.append(resolveICloudContainer(container, hostBundleId: hostBundleId))

            case let .iCloudCloudKitContainer(container):
                iCloudServices.insert("CloudKit")
                cloudKitContainerIdentifiers.append(resolveICloudContainer(container, hostBundleId: hostBundleId))

            case let .iCloudKeyValueStore(id):
                ubiquityKVStoreIdentifier = resolvePrefixedIdentifier(id, defaultUnprefixed: hostBundleId, afterComponents: 2)

            case let .applePayMerchant(id):
                merchantIdentifiers.insert(resolveMerchantIdentifier(id, hostBundleId: hostBundleId))

            case let .walletPassType(id):
                passTypeIdentifiers.insert(resolvePassTypeIdentifier(id, hostBundleId: hostBundleId))

            case let .associatedDomains(domains):
                associatedDomains.formUnion(domains)
            }
        }

        var entitlements: [String: Plist.Value] = [:]

        if !keychainAccessGroups.isEmpty {
            entitlements["keychain-access-groups"] = .array(keychainAccessGroups.sorted().map { .string($0) })
        }

        if !applicationGroups.isEmpty {
            entitlements["com.apple.security.application-groups"] = .array(applicationGroups.sorted().map { .string($0) })
        }

        let uniqueUbiquityContainers = uniquePreservingOrder(ubiquityContainerIdentifiers)
        if !uniqueUbiquityContainers.isEmpty {
            entitlements["com.apple.developer.ubiquity-container-identifiers"] =
                .array(uniqueUbiquityContainers.map { .string($0) })
        }

        let uniqueCloudKitContainers = uniquePreservingOrder(cloudKitContainerIdentifiers)
        if !uniqueCloudKitContainers.isEmpty {
            entitlements["com.apple.developer.icloud-container-identifiers"] =
                .array(uniqueCloudKitContainers.map { .string($0) })
        }

        if !iCloudServices.isEmpty {
            entitlements["com.apple.developer.icloud-services"] = .array(iCloudServices.sorted().map { .string($0) })
        }

        if let ubiquityKVStoreIdentifier {
            entitlements["com.apple.developer.ubiquity-kvstore-identifier"] = .string(ubiquityKVStoreIdentifier)
        }

        if !merchantIdentifiers.isEmpty {
            entitlements["com.apple.developer.in-app-payments"] = .array(merchantIdentifiers.sorted().map { .string($0) })
        }

        if !passTypeIdentifiers.isEmpty {
            entitlements["com.apple.developer.pass-type-identifiers"] = .array(passTypeIdentifiers.sorted().map { .string($0) })
        }

        if !associatedDomains.isEmpty {
            entitlements["com.apple.developer.associated-domains"] = .array(associatedDomains.sorted().map { .string($0) })
        }

        return entitlements
    }

    /// Resolves a Keychain Access Group entry (`keychain-access-groups`).
    ///
    /// Default: `$(AppIdentifierPrefix)<host bundle id>`
    private static func resolveKeychainAccessGroup(_ id: Capability.Identifier, hostBundleId: String) -> String {
        resolvePrefixedIdentifier(id, defaultUnprefixed: hostBundleId, afterComponents: 2)
    }

    /// Resolves an App Group identifier entry (`com.apple.security.application-groups`).
    ///
    /// Default: `group.<host bundle id>`
    private static func resolveAppGroup(_ id: Capability.Identifier, hostBundleId: String) -> String {
        switch id {
        case .default:
            return "group.\(hostBundleId)"
        case let .custom(id: customId, namespacing: namespacing):
            let trimmed = customId.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.hasPrefix("group.") else {
                fatalError(
                    """
                    🛑 INVALID APP GROUP IDENTIFIER 🛑
                    ---------------------------------------------------
                    Capability: App Groups
                    Rule: Custom App Group identifiers must start with 'group.'.
                    Value: \(customId)
                    ---------------------------------------------------
                    """
                )
            }

            return applyNamespacing(trimmed, namespacing: namespacing, afterComponents: 3)
        }
    }

    /// Resolves an iCloud container identifier (used for iCloud Documents and CloudKit containers).
    ///
    /// Default: `iCloud.<host bundle id>`
    private static func resolveICloudContainer(_ id: Capability.Identifier, hostBundleId: String) -> String {
        switch id {
        case .default:
            return "iCloud.\(hostBundleId)"
        case let .custom(id: customId, namespacing: namespacing):
            let trimmed = customId.trimmingCharacters(in: .whitespacesAndNewlines)
            return applyNamespacing(trimmed, namespacing: namespacing, afterComponents: 3)
        }
    }

    /// Resolves an Apple Pay merchant identifier entry (`com.apple.developer.in-app-payments`).
    ///
    /// Default: `merchant.<host bundle id>`
    private static func resolveMerchantIdentifier(_ id: Capability.Identifier, hostBundleId: String) -> String {
        switch id {
        case .default:
            return "merchant.\(hostBundleId)"
        case let .custom(id: customId, namespacing: namespacing):
            let trimmed = customId.trimmingCharacters(in: .whitespacesAndNewlines)
            return applyNamespacing(trimmed, namespacing: namespacing, afterComponents: 3)
        }
    }

    /// Resolves a Wallet pass type identifier entry (`com.apple.developer.pass-type-identifiers`).
    ///
    /// Default: `pass.<host bundle id>`
    private static func resolvePassTypeIdentifier(_ id: Capability.Identifier, hostBundleId: String) -> String {
        switch id {
        case .default:
            return "pass.\(hostBundleId)"
        case let .custom(id: customId, namespacing: namespacing):
            let trimmed = customId.trimmingCharacters(in: .whitespacesAndNewlines)
            return applyNamespacing(trimmed, namespacing: namespacing, afterComponents: 3)
        }
    }

    /// Resolves an identifier that must be prefixed with the App Identifier Prefix.
    ///
    /// The returned value uses the `$(AppIdentifierPrefix)` macro so Xcode can inject the correct
    /// Team/App ID prefix at build time.
    private static func resolvePrefixedIdentifier(
        _ id: Capability.Identifier,
        defaultUnprefixed: String,
        afterComponents: Int
    ) -> String {
        let unprefixed: String
        switch id {
        case .default:
            unprefixed = defaultUnprefixed
        case let .custom(id: customId, namespacing: namespacing):
            let trimmed = customId.trimmingCharacters(in: .whitespacesAndNewlines)
            unprefixed = applyNamespacing(trimmed, namespacing: namespacing, afterComponents: afterComponents)
        }

        return "$(AppIdentifierPrefix)\(unprefixed)"
    }

    /// Applies local namespacing rules to a custom identifier.
    private static func applyNamespacing(_ identifier: String, namespacing: Capability.Namespacing, afterComponents: Int) -> String {
        switch namespacing {
        case .none:
            return identifier
        case .environmentSuffix:
            return ConfigurationHelper.applyEnvironmentSuffix(to: identifier, afterComponents: afterComponents)
        }
    }

    /// De-duplicates an array while preserving the first occurrence order.
    ///
    /// This is important for entitlements where order can be semantically meaningful (for example,
    /// the first iCloud container is treated as the “primary” container).
    private static func uniquePreservingOrder(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        var result: [String] = []
        result.reserveCapacity(values.count)

        for value in values where seen.insert(value).inserted {
            result.append(value)
        }

        return result
    }
}
