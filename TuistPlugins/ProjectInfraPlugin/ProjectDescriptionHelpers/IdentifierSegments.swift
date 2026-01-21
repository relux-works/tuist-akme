import Foundation

/// Normalization helpers for identifier segments we control (bundle IDs, capability IDs, etc.).
///
/// This intentionally does not attempt to validate or transform Apple/Xcode macros or prefixes
/// like `iCloud.` or `$(TeamIdentifierPrefix)`.
enum IdentifierSegments {
    /// Normalizes a dot-separated string into one or more lowercase identifier segments.
    ///
    /// Each input segment is normalized independently.
    static func normalizeDotSeparated(_ raw: String) -> [String] {
        raw
            .split(separator: ".")
            .map(String.init)
            .map(normalizeSegment)
            .filter { !$0.isEmpty }
    }

    /// Normalizes a single identifier segment.
    ///
    /// Rules:
    /// - strip non-alphanumeric characters
    /// - lowercase the result
    /// - ensure the first character is a letter (prefix with `x` if needed)
    static func normalizeSegment(_ raw: String) -> String {
        let stripped = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .unicodeScalars
            .filter { CharacterSet.alphanumerics.contains($0) }
            .map(Character.init)

        var result = String(stripped).lowercased()
        guard !result.isEmpty else { return "" }

        if let first = result.unicodeScalars.first, !CharacterSet.letters.contains(first) {
            result = "x" + result
        }

        return result
    }
}

