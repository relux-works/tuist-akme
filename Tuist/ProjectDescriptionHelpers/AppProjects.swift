import ProjectDescription
import ProjectInfraPlugin

/// Canonical cross-project target references for apps and extensions.
///
/// Keep these in one place to avoid sprinkling raw target names and paths across manifests.
public enum AppProjects {
    /// iOS app projects and targets.
    public enum iOS {
        /// Widget extension target embedded in the iOS host app.
        public static let acmeWidget = ProjectTargetRef(
            target: "AcmeWidget",
            path: .relativeToRoot("Apps/iOSApp/Extensions/AcmeWidget")
        )
    }
}
