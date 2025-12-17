// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

private enum BuildEnvironment: CaseIterable {
    case debug
    case release

    var configurationName: ConfigurationName {
        switch self {
        case .debug: return .debug
        case .release: return .release
        }
    }

    func settings() -> SettingsDictionary {
        var settings: SettingsDictionary = [:]

        settings["IPHONEOS_DEPLOYMENT_TARGET"] = "16.0"
        settings["MACOSX_DEPLOYMENT_TARGET"] = "13.0"
        settings["SWIFT_VERSION"] = "5.9"

        switch self {
        case .debug:
            settings["ENABLE_TESTABILITY"] = "YES"
            settings["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = "$(inherited) DEBUG"
            settings["GCC_PREPROCESSOR_DEFINITIONS"] = "$(inherited) DEBUG=1"
            settings["SWIFT_OPTIMIZATION_LEVEL"] = "-Onone"
            settings["SWIFT_COMPILATION_MODE"] = "singlefile"
            settings["DEBUG_INFORMATION_FORMAT"] = "dwarf"
        case .release:
            settings["ENABLE_TESTABILITY"] = "NO"
            settings["SWIFT_OPTIMIZATION_LEVEL"] = "-O"
            settings["SWIFT_COMPILATION_MODE"] = "wholemodule"
            settings["DEBUG_INFORMATION_FORMAT"] = "dwarf-with-dsym"
        }

        return settings
    }

    func configuration(with settings: SettingsDictionary) -> Configuration {
        switch self {
        case .debug:
            return .debug(name: configurationName, settings: settings)
        case .release:
            return .release(name: configurationName, settings: settings)
        }
    }
}

private extension Settings {
    static var externalDependencyModuleSettings: Settings {
        .settings(
            configurations: BuildEnvironment.allCases.map { environment in
                var settings = environment.settings()
                settings["ENABLE_MODULE_VERIFIER"] = "NO"
                return environment.configuration(with: settings)
            }
        )
    }
}

let packageSettings = PackageSettings(
    productTypes: [
        "Kingfisher": .framework,
        // Define external frameworks as dynamic by default to share memory
    ],
    baseSettings: .externalDependencyModuleSettings
)
#endif

let package = Package(
    name: "AcmeAppDependencies",
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.10.0"),
        // Add other dependencies here
    ]
)
