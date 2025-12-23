import ProjectInfraPlugin

/// Project-specific typed constructors for `Tag`.
///
/// These helpers keep manifests free of raw `"<key>:<value>"` strings while still producing the
/// exact serialization Tuist expects (`TargetMetadata.tags`).
public extension Tag {
    /// Creates an ad-hoc tag for a known `TagKey`.
    ///
    /// Prefer typed helpers when available (e.g. `Tag.owner(_:)`, `Tag.area(_:)`, `Tag.layer(_:)`),
    /// and use this as an escape hatch when the value is intentionally free-form.
    static func key(_ key: TagKey, _ value: String) -> Tag {
        Tag.key(key.rawValue, value)
    }

    /// Creates an `owner:<owner>` tag.
    static func owner(_ value: OwnerTagValue) -> Tag {
        Tag.key(.owner, value.rawValue)
    }

    /// Creates an `area:<area>` tag.
    static func area(_ value: AreaTagValue) -> Tag {
        Tag.key(.area, value.rawValue)
    }

    /// Creates a `layer:<layer>` tag.
    ///
    /// Use this to encode architectural layering (e.g. `.layer(.feature)`), rather than using
    /// broad ownership tags like `owner:features`.
    static func layer(_ value: ModuleLayer) -> Tag {
        Tag.key(.layer, value.rawValue)
    }

    /// Creates a `platform:<platform>` tag.
    static func platform(_ value: PlatformTagValue) -> Tag {
        Tag.key(.platform, value.rawValue)
    }
}
