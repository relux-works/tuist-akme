import ProjectDescription

public enum EntitlementsFactory {
    public static func make(hostBundleId: String, capabilities: [Capability]) -> Entitlements? {
        let dictionary = makeDictionary(hostBundleId: hostBundleId, capabilities: capabilities)
        guard !dictionary.isEmpty else { return nil }
        return .dictionary(dictionary)
    }

    public static func makeDictionary(hostBundleId: String, capabilities: [Capability]) -> [String: Plist.Value] {
        var keychainAccessGroups: Set<String> = []
        var applicationGroups: Set<String> = []
        var ubiquityContainerIdentifiers: Set<String> = []
        var cloudKitContainerIdentifiers: Set<String> = []
        var iCloudServices: Set<String> = []
        var ubiquityKVStoreIdentifier: String?
        var merchantIdentifiers: Set<String> = []
        var passTypeIdentifiers: Set<String> = []
        var associatedDomains: Set<String> = []

        for capability in capabilities {
            switch capability.kind {
            case let .keychainSharing(group):
                keychainAccessGroups.insert(resolveKeychainAccessGroup(group, hostBundleId: hostBundleId))

            case let .appGroups(group):
                applicationGroups.insert(resolveAppGroup(group, hostBundleId: hostBundleId))

            case let .iCloudUbiquityContainer(container):
                iCloudServices.insert("CloudDocuments")
                ubiquityContainerIdentifiers.insert(resolveICloudContainer(container, hostBundleId: hostBundleId))

            case let .iCloudCloudKitContainer(container):
                iCloudServices.insert("CloudKit")
                cloudKitContainerIdentifiers.insert(resolveICloudContainer(container, hostBundleId: hostBundleId))

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

        if !ubiquityContainerIdentifiers.isEmpty {
            entitlements["com.apple.developer.ubiquity-container-identifiers"] =
                .array(ubiquityContainerIdentifiers.sorted().map { .string($0) })
        }

        if !cloudKitContainerIdentifiers.isEmpty {
            entitlements["com.apple.developer.icloud-container-identifiers"] =
                .array(cloudKitContainerIdentifiers.sorted().map { .string($0) })
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

    private static func resolveKeychainAccessGroup(_ id: Capability.Identifier, hostBundleId: String) -> String {
        resolvePrefixedIdentifier(id, defaultUnprefixed: hostBundleId, afterComponents: 2)
    }

    private static func resolveAppGroup(_ id: Capability.Identifier, hostBundleId: String) -> String {
        switch id {
        case .default:
            return "group.\(hostBundleId)"
        case let .custom(id: customId, namespacing: namespacing):
            return applyNamespacing(customId, namespacing: namespacing, afterComponents: 3)
        }
    }

    private static func resolveICloudContainer(_ id: Capability.Identifier, hostBundleId: String) -> String {
        switch id {
        case .default:
            return "iCloud.\(hostBundleId)"
        case let .custom(id: customId, namespacing: namespacing):
            return applyNamespacing(customId, namespacing: namespacing, afterComponents: 3)
        }
    }

    private static func resolveMerchantIdentifier(_ id: Capability.Identifier, hostBundleId: String) -> String {
        switch id {
        case .default:
            return "merchant.\(hostBundleId)"
        case let .custom(id: customId, namespacing: namespacing):
            return applyNamespacing(customId, namespacing: namespacing, afterComponents: 3)
        }
    }

    private static func resolvePassTypeIdentifier(_ id: Capability.Identifier, hostBundleId: String) -> String {
        switch id {
        case .default:
            return "pass.\(hostBundleId)"
        case let .custom(id: customId, namespacing: namespacing):
            return applyNamespacing(customId, namespacing: namespacing, afterComponents: 3)
        }
    }

    private static func resolvePrefixedIdentifier(
        _ id: Capability.Identifier,
        defaultUnprefixed: String,
        afterComponents: Int
    ) -> String {
        let unprefixed: String = switch id {
        case .default:
            defaultUnprefixed
        case let .custom(id: customId, namespacing: namespacing):
            applyNamespacing(customId, namespacing: namespacing, afterComponents: afterComponents)
        }

        return "$(AppIdentifierPrefix)\(unprefixed)"
    }

    private static func applyNamespacing(_ identifier: String, namespacing: Capability.Namespacing, afterComponents: Int) -> String {
        switch namespacing {
        case .none:
            return identifier
        case .environmentSuffix:
            return ConfigurationHelper.applyEnvironmentSuffix(to: identifier, afterComponents: afterComponents)
        }
    }
}
