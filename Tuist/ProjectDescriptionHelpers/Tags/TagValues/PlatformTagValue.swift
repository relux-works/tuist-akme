//
//  PlatformTagValue.swift
//  Manifests
//
//  Created by Ivan Wb on 24.12.2025.
//


/// A canonical value for the `platform` tag key.
///
/// Use when a module or test target is platform-specific and you want to focus generation/CI.
public enum PlatformTagValue: String, CaseIterable, Sendable {
    /// iOS-only targets.
    case iOS = "ios"

    /// macOS-only targets.
    case macOS = "macos"

    /// tvOS-only targets.
    case tvOS = "tvos"

    /// watchOS-only targets.
    case watchOS = "watchos"

    /// visionOS-only targets.
    case visionOS = "visionos"
}
