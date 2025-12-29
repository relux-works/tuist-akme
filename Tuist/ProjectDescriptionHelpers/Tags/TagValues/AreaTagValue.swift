//
//  AreaTagValue.swift
//  Manifests
//
//  Created by Ivan Wb on 24.12.2025.
//


/// A canonical value for the `area` tag key.
///
/// Areas represent “what the code is about” (domain slice), and can differ from ownership.
public struct AreaTagValue: Hashable, Sendable {
    /// The string value used in the serialized `area:<value>` tag.
    ///
    /// Example:
    /// - `AreaTagValue.auth.rawValue == "auth"`
    /// - `Tag.area(.auth).value == "area:auth"`
    public let rawValue: String

    /// Creates an area tag value.
    private init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Canonical `area` tag values.
///
/// Add new areas here to keep call sites autocomplete-friendly and consistent.
public extension AreaTagValue {
    /// Authentication & authorization domain area.
    static let auth = AreaTagValue("auth")
}
