import ProjectDescription

public enum ProjectFactory {
    public static func makeFeature(
        module: ModuleID,
        destinations: Destinations = .iOS,
        product: Product = .framework,
        dependencies: [Dep],
        testDependencies: [Dep] = [],
        hasResources: Bool = false
    ) -> Project {
        let interface = TargetFactory.makeInterface(
            module: module,
            destinations: destinations,
            dependencies: []
        )

        let implDeps: [TargetDependency] = [.target(name: interface.name)] + dependencies.map(\.target)
        let impl = TargetFactory.makeImpl(
            module: module,
            destinations: destinations,
            product: product,
            dependencies: implDeps,
            resources: hasResources ? ["Resources/**"] : nil
        )

        let testing = TargetFactory.makeTesting(
            module: module,
            destinations: destinations,
            dependencies: [.target(name: interface.name)]
        )

        let testDeps: [TargetDependency] = [.target(name: impl.name), .target(name: testing.name)] + testDependencies.map(\.target)
        let tests = TargetFactory.makeTests(
            module: module,
            destinations: destinations,
            dependencies: testDeps
        )

        let scheme = Scheme.scheme(
            name: module.name,
            shared: true,
            buildAction: .buildAction(targets: [.target(impl.name)]),
            testAction: .targets([.testableTarget(target: .target(tests.name))], configuration: .debug)
        )

        return Project(
            name: module.name,
            targets: [interface, impl, testing, tests],
            schemes: [scheme]
        )
    }
}
