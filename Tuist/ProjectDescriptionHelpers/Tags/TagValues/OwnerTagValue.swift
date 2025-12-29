//
//  OwnerTagValue.swift
//  Manifests
//
//  Created by Ivan Wb on 24.12.2025.
//


/// A canonical value for the `owner` tag key.
///
/// Prefer adding new values here (instead of sprinkling raw strings across manifests) so
/// autocomplete works and CI queries stay consistent.
public struct OwnerTagValue: Hashable, Sendable {
    /// The string value used in the serialized `owner:<value>` tag.
    ///
    /// Example:
    /// - `OwnerTagValue.checkout.rawValue == "checkout"`
    /// - `Tag.owner(.checkout).value == "owner:checkout"`
    public let rawValue: String

    /// Creates an owner tag value.
    private init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Canonical `owner` tag values.
///
/// Add new owners here to keep call sites autocomplete-friendly and consistent.
public extension OwnerTagValue {
    /// Checkout/Payments ownership group.
    static let checkout = OwnerTagValue("checkout")

    /// Identity/Auth ownership group.
    static let identity = OwnerTagValue("identity")

    /// Platform/Infrastructure ownership group.
    static let platform = OwnerTagValue("platform")

    /// Legacy catch-all owner tag. Prefer a specific owner and use `Tag.layer(.feature)` instead.
    @available(
        *,
        deprecated,
        message: "Avoid catch-all owners (e.g. 'features'). Prefer a specific owner like 'checkout'/'identity', and use Tag.layer(.feature) for Feature-layer modules."
    )
    static let features = OwnerTagValue("features")
}
