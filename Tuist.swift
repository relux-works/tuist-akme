import ProjectDescription

let config = Tuist(
    project: .tuist(
        compatibleXcodeVersions: .upToNextMajor("26.0"),
        plugins: [
            .local(path: .relativeToRoot("TuistPlugins/ProjectInfraPlugin")),
        ],
        generationOptions: .options(
            disableSandbox: false
        )
    )
)
