/// Project-wide target tags used for ownership, CI, and focus queries.
///
/// Tags are serialized as `"<key>:<value>"` (for example `owner:identity`) and applied to targets
/// via `Target.metadata.tags`.
///
/// These tags are intended to answer four different questions:
/// - **Who owns this?** (`owner:<owner>`)
/// - **What is it about?** (`area:<area>`)
/// - **Where does it live architecturally?** (`layer:<layer>`)
/// - **Which platform slice does it target?** (`platform:<platform>`)
///
/// **Nomenclature**
/// - `owner:<owner>`: Who is accountable for the module (team/oncall). Prefer **specific owners**
///   like `owner:checkout` or `owner:identity` (avoid catch-all values like `owner:features`).
/// - `layer:<layer>`: Architectural layer (e.g. `layer:feature`, `layer:core`). This is the right
///   place to encode “this is a Feature-layer module”, not `owner:features`.
/// - `area:<area>`: What the code is about (business/domain slice), independent from ownership
///   (e.g. `area:auth`, `area:payments`).
/// - `platform:<platform>`: Platform slice for CI/focus (e.g. `platform:ios`, `platform:macos`).
///   Use this only when a module meaningfully differs by platform.
///
/// **Recommended combinations**
/// - Feature module: `owner:*` + `area:*` + `layer:feature` (optionally `platform:*`)
/// - Core module: `owner:*` + `area:*` + `layer:core`
/// - Shared/Utility module: `owner:*` + `layer:shared|utility` (area optional)
///
/// Example (in `Project.swift`):
/// ```swift
/// tags: [
///     .owner(.identity),
///     .area(.auth),
///     .layer(.feature),
/// ]
/// ```
///
/// Example (focus generation):
/// - `tuist generate tag:owner:identity`
/// - `tuist generate tag:layer:core`
///
/// Notes:
/// - Tags are currently applied to a module’s **Impl** and **Tests** targets (via
///   `ProjectFactory`/`TargetFactory`).
public struct TagKey: Hashable, Sendable {
    /// The string key used in the serialized tag value.
    ///
    /// Example:
    /// - `TagKey.owner.rawValue == "owner"`
    /// - `Tag.key(.owner, "checkout").value == "owner:checkout"`
    public let rawValue: String

    private init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

/// The project's canonical tag keys.
///
/// Keep these stable because CI queries depend on them.
public extension TagKey {
    /// Who is accountable for the module (team/oncall).
    ///
    /// Prefer using `Tag.owner(_:)` with a typed `OwnerTagValue`.
    static let owner = TagKey("owner")

    /// What the code is about (business/domain slice), independent from ownership.
    ///
    /// Prefer using `Tag.area(_:)` with a typed `AreaTagValue`.
    static let area = TagKey("area")

    /// Architectural layer of the module (e.g. feature/core/shared/utility/app).
    ///
    /// Prefer using `Tag.layer(_:)` with `ModuleLayer`.
    static let layer = TagKey("layer")

    /// Platform slice used for CI/focus when relevant (e.g. ios/macos).
    ///
    /// Prefer using `Tag.platform(_:)` with `PlatformTagValue`.
    static let platform = TagKey("platform")
}
