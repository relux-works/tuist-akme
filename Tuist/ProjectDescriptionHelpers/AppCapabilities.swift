import ProjectInfraPlugin



/// Canonical capability definitions shared across the host app and its extensions.
///
/// Keep this centralized so app extensions can "inherit" capabilities without duplicating
/// identifier logic across multiple `Project.swift` manifests.
extension [Capability] {
    public static let iOSPlusAppex: [Capability] = [
        .appGroups(),
        .iCloudCloudKitContainer()
    ]
}
