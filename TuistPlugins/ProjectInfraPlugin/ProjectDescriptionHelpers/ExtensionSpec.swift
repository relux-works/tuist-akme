import ProjectDescription

/// A lightweight specification for creating an app extension target.
///
/// `ProjectFactory.makeApp(extensions:)` turns `ExtensionSpec` instances into `Target`s, enforcing:
/// - Bundle IDs are derived from the host app's bundle ID (including any environment suffix).
/// - Signing settings (team ID) are inherited from the host app when provided.
public struct ExtensionSpec {
    /// Extension target name.
    public let name: String

    /// App extension bundle identifier type segment.
    ///
    /// Used to build the bundle ID as: `<hostBundleId>.appex.<type>[.<name>]`.
    public let bundleIdType: String

    /// Optional app extension bundle identifier name segment(s).
    public let bundleIdName: String?

    /// The Tuist product type (typically `.appExtension`).
    public let product: Product

    /// Info.plist definition for the extension target.
    public let infoPlist: InfoPlist

    /// Source file globs for the extension target.
    public let sources: SourceFilesList

    /// Optional resource globs for the extension target.
    public let resources: ResourceFileElements?

    /// Target dependencies of the extension (in addition to any host wiring).
    public let dependencies: [TargetDependency]

    /// Additional build settings for the extension target.
    public let settings: SettingsDictionary

    /// The `NSExtensionPointIdentifier` value for the extension (e.g. WidgetKit).
    public let extensionPointIdentifier: String

    /// Creates an extension specification.
    ///
    /// When `sources` is omitted, it defaults to `Extensions/<name>/Sources/**`.
    public init(
        name: String,
        bundleIdType: String,
        bundleIdName: String? = nil,
        product: Product,
        infoPlist: InfoPlist = .extendingDefault(with: [:]),
        sources: SourceFilesList? = nil,
        resources: ResourceFileElements? = nil,
        dependencies: [TargetDependency] = [],
        settings: SettingsDictionary = [:],
        extensionPointIdentifier: String = "com.apple.widgetkit-extension"
    ) {
        self.name = name
        self.bundleIdType = bundleIdType
        self.bundleIdName = bundleIdName
        self.product = product
        self.infoPlist = infoPlist
        self.sources = sources ?? ["Extensions/\(name)/Sources/**"]
        self.resources = resources
        self.dependencies = dependencies
        self.settings = settings
        self.extensionPointIdentifier = extensionPointIdentifier
    }
}
