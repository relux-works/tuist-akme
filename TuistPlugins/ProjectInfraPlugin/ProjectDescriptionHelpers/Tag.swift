import Foundation

/// A lightweight wrapper around a target metadata tag string.
///
/// Tags are ultimately stored on targets as raw strings (`TargetMetadata.tags`), but using `Tag`
/// keeps factory APIs type-safe and enables project-specific typed constructors in
/// `Tuist/ProjectDescriptionHelpers/Tags.swift`.
///
/// The canonical serialized representation is `value`, typically formatted as `"<key>:<value>"`
/// (for example `owner:identity`).
public struct Tag: Hashable, Sendable, ExpressibleByStringLiteral {
    /// The serialized tag value.
    public let value: String

    /// Creates a tag from an already-serialized value.
    ///
    /// Prefer using `Tag.key(_:_:)` (or a project-provided typed constructor like `.owner(.identity)`)
    /// where possible.
    public init(_ value: String) {
        self.value = value
    }

    /// Creates a tag from a string literal (escape hatch).
    ///
    /// This is intentionally supported for rare cases, but most call sites should use typed helpers.
    public init(stringLiteral value: StringLiteralType) {
        self.value = value
    }

    /// Creates a tag from a key/value pair by serializing it as `"<key>:<value>"`.
    public static func key(_ key: String, _ value: String) -> Tag {
        Tag("\(key):\(value)")
    }
}
