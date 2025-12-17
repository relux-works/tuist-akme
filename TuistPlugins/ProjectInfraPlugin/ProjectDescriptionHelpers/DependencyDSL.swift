import ProjectDescription

public struct Dep {
    public let target: TargetDependency

    public init(_ target: TargetDependency) {
        self.target = target
    }

    public static func interface(_ module: ModuleID) -> Dep {
        .init(.project(target: module.interfaceTarget, path: module.path))
    }

    public static func testing(_ module: ModuleID) -> Dep {
        .init(.project(target: module.testingTarget, path: module.path))
    }

    public static func external(_ name: String) -> Dep {
        .init(.external(name: name))
    }
}

