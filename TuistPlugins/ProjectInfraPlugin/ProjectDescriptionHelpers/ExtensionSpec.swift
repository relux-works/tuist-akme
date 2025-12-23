import ProjectDescription

/// A lightweight specification for creating an app extension target.
///
/// `ProjectFactory.makeApp(extensions:)` turns `ExtensionSpec` instances into `Target`s, enforcing:
/// - Bundle IDs are derived from the host app's bundle ID (including any environment suffix).
/// - Signing settings (team ID) are inherited from the host app when provided.
public struct ExtensionSpec {
    public let name: String
    public let product: Product
    public let infoPlist: InfoPlist
    public let sources: SourceFilesList
    public let resources: ResourceFileElements?
    public let dependencies: [TargetDependency]
    public let settings: SettingsDictionary
    public let extensionPointIdentifier: String

    public init(
        name: String,
        product: Product,
        infoPlist: InfoPlist = .extendingDefault(with: [:]),
        sources: SourceFilesList? = nil,
        resources: ResourceFileElements? = nil,
        dependencies: [TargetDependency] = [],
        settings: SettingsDictionary = [:],
        extensionPointIdentifier: String = "com.apple.widgetkit-extension"
    ) {
        self.name = name
        self.product = product
        self.infoPlist = infoPlist
        self.sources = sources ?? ["Extensions/\(name)/Sources/**"]
        self.resources = resources
        self.dependencies = dependencies
        self.settings = settings
        self.extensionPointIdentifier = extensionPointIdentifier
    }
}
