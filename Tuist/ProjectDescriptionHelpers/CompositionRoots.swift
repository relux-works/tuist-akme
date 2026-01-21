import ProjectInfraPlugin

/// Project-specific composition root shortcuts.
///
/// Composition roots live under `Modules/CompositionRoots/` and are referenced from app manifests
/// via `ProjectFactory.makeHostApp` / `ProjectFactory.makeAppExtensionProject`.
public extension CompositionRoot {
    /// Main application composition root (links the full feature graph).
    static let app = CompositionRoot(ModuleID.compositionRoot(.appCompositionRoot, scope: .darwin))

    /// Widget composition root (curated graph for widget memory/runtime constraints).
    static let widget = CompositionRoot(ModuleID.compositionRoot(.widgetCompositionRoot, scope: .ios))
}
