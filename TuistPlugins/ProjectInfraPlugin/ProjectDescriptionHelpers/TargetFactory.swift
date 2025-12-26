import ProjectDescription

public enum TargetFactory {
    private static var developmentTeamIdFromEnvironment: String? {
        let value = Environment.developmentTeamId.getString(default: "")
        return value.isEmpty ? nil : value
    }

    private static func deploymentTargets(for destinations: Destinations) -> DeploymentTargets {
        let platforms = destinations.platforms
        return .multiplatform(
            iOS: platforms.contains(.iOS) ? "16.0" : nil,
            macOS: platforms.contains(.macOS) ? "13.0" : nil,
            watchOS: nil,
            tvOS: nil,
            visionOS: nil
        )
    }

    private static func makeSettings(
        additionalSettings: SettingsDictionary = [:],
        developmentTeamId: String? = nil,
        automaticSigning: Bool = false
    ) -> Settings {
        let resolvedDevelopmentTeamId = developmentTeamId ?? developmentTeamIdFromEnvironment
        let signing: SettingsDictionary = {
            guard automaticSigning else { return [:] }

            var settings: SettingsDictionary = [
                "CODE_SIGN_STYLE": "Automatic",
            ]

            if let resolvedDevelopmentTeamId, !resolvedDevelopmentTeamId.isEmpty {
                settings["DEVELOPMENT_TEAM"] = .string(resolvedDevelopmentTeamId)
            }

            return settings
        }()

        guard !additionalSettings.isEmpty || !signing.isEmpty else { return .regular }

        return .settings(
            configurations: BuildEnvironment.allCases.map { environment in
                let merged = environment
                    .settings()
                    .merging(signing) { _, new in new }
                    .merging(additionalSettings) { _, new in new }

                switch environment {
                case .debug:
                    return .debug(name: environment.configurationName, settings: merged)
                case .release:
                    return .release(name: environment.configurationName, settings: merged)
                }
            }
        )
    }

    public static func makeInterface(
        module: ModuleID,
        destinations: Destinations,
        dependencies: [TargetDependency]
    ) -> Target {
        .target(
            name: module.interfaceTarget,
            destinations: destinations,
            product: .framework,
            bundleId: BundleID.module(module, kind: .interface),
            deploymentTargets: deploymentTargets(for: destinations),
            sources: ["Interface/**"],
            dependencies: dependencies,
            settings: makeSettings()
        )
    }

    public static func makeImpl(
        module: ModuleID,
        destinations: Destinations,
        product: Product,
        dependencies: [TargetDependency],
        resources: ResourceFileElements?,
        additionalSettings: SettingsDictionary = [:],
        developmentTeamId: String? = nil,
        tags: [Tag] = []
    ) -> Target {
        let settings = makeSettings(
            additionalSettings: additionalSettings,
            developmentTeamId: developmentTeamId
        )

        let metadata: TargetMetadata = tags.isEmpty
            ? .default
            : .metadata(tags: tags.map(\.value))

        return .target(
            name: module.implTarget,
            destinations: destinations,
            product: product,
            bundleId: BundleID.module(module, kind: .impl),
            deploymentTargets: deploymentTargets(for: destinations),
            sources: ["Sources/**"],
            resources: resources,
            dependencies: dependencies,
            settings: settings,
            metadata: metadata
        )
    }

    public static func makeTesting(
        module: ModuleID,
        destinations: Destinations,
        dependencies: [TargetDependency]
    ) -> Target {
        .target(
            name: module.testingTarget,
            destinations: destinations,
            product: .staticFramework,
            bundleId: BundleID.module(module, kind: .testing),
            deploymentTargets: deploymentTargets(for: destinations),
            sources: ["Testing/**"],
            dependencies: dependencies,
            settings: makeSettings()
        )
    }

    public static func makeTests(
        module: ModuleID,
        destinations: Destinations,
        dependencies: [TargetDependency],
        tags: [Tag] = []
    ) -> Target {
        let metadata: TargetMetadata = tags.isEmpty
            ? .default
            : .metadata(tags: tags.map(\.value))

        return .target(
            name: module.testsTarget,
            destinations: destinations,
            product: .unitTests,
            bundleId: BundleID.module(module, kind: .tests),
            deploymentTargets: deploymentTargets(for: destinations),
            sources: ["Tests/**"],
            dependencies: dependencies,
            settings: makeSettings(),
            metadata: metadata
        )
    }

    public static func makeApp(
        name: String,
        destinations: Destinations,
        bundleId: String,
        deploymentTargets: DeploymentTargets?,
        entitlements: Entitlements? = nil,
        infoPlist: InfoPlist,
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        dependencies: [TargetDependency],
        additionalSettings: SettingsDictionary = [:],
        developmentTeamId: String? = nil,
        automaticSigning: Bool = true
    ) -> Target {
        .target(
            name: name,
            destinations: destinations,
            product: .app,
            bundleId: bundleId,
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            dependencies: dependencies,
            settings: makeSettings(
                additionalSettings: additionalSettings,
                developmentTeamId: developmentTeamId,
                automaticSigning: automaticSigning
            )
        )
    }

    public static func makeExtension(
        name: String,
        hostBundleId: String,
        destinations: Destinations,
        product: Product,
        infoPlist: InfoPlist = .extendingDefault(with: [:]),
        entitlements: Entitlements? = nil,
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        dependencies: [TargetDependency] = [],
        additionalSettings: SettingsDictionary = [:],
        developmentTeamId: String? = nil,
        extensionPointIdentifier: String = "com.apple.widgetkit-extension",
        bundleIdComponent: String? = nil
    ) -> Target {
        let resolvedBundleIdComponent = bundleIdComponent ?? name.lowercased()
        let bundleId = "\(hostBundleId).\(resolvedBundleIdComponent)"

        let enforcedInfoPlist: InfoPlist = {
            let nsExtension: Plist.Value = [
                "NSExtensionPointIdentifier": .string(extensionPointIdentifier),
            ]

            switch infoPlist {
            case .default:
                return .extendingDefault(with: [
                    "NSExtension": nsExtension,
                ])
            case let .extendingDefault(with: dictionary):
                return .extendingDefault(with: dictionary.merging(["NSExtension": nsExtension]) { _, new in new })
            case let .dictionary(dictionary):
                return .dictionary(dictionary.merging(["NSExtension": nsExtension]) { _, new in new })
            case .file:
                return infoPlist
            default:
                return infoPlist
            }
        }()

        return .target(
            name: name,
            destinations: destinations,
            product: product,
            bundleId: bundleId,
            deploymentTargets: deploymentTargets(for: destinations),
            infoPlist: enforcedInfoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            dependencies: dependencies,
            settings: makeSettings(
                additionalSettings: additionalSettings,
                developmentTeamId: developmentTeamId,
                automaticSigning: true
            )
        )
    }
}
