import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

extension Project {
  /// Helper function to create the Project for this ExampleApp
  public static func app(
    name: String,
    destinations: Destinations,
    dependencies: [TargetDependency],
    additionalTargets: [String],
    additionalSourcePaths: [String],
    additionalResourcePaths: [String]
  ) -> Project {
    var targets = makeAppTargets(
      name: name,
      destinations: destinations,
      dependencies: dependencies,
      additionalSourcePaths: additionalSourcePaths,
      additionalResourcePaths: additionalResourcePaths
    )
    targets += additionalTargets.flatMap({ makeFrameworkTargets(name: $0, destinations: destinations) })
    return Project(
      name: name,
      organizationName: "Archive",
      settings: Settings.settings(
        base: [:],
        configurations: [
          .debug(
            name: "Debug",
            settings: [:],
            xcconfig: "Sample.xcconfig")
        ],
        defaultSettings: .recommended
      ),
      targets: targets
    )
  }
  
  // MARK: - Private
  
  /// Helper function to create a framework target and an associated unit test target
  private static func makeFrameworkTargets(name: String, destinations: Destinations) -> [Target] {
    let sources = Target(
      name: name,
      destinations: destinations,
      product: .framework,
      bundleId: "com.archive.\(name)",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["../Sources/**"],
      resources: []
    )
    let tests = Target(
      name: "\(name)Tests",
      destinations: destinations,
      product: .unitTests,
      bundleId: "com.archive.\(name)Tests",
      infoPlist: .default,
      sources: ["Targets/\(name)/Tests/**"],
      resources: [],
      dependencies: [.target(name: name)]
    )
    return [sources, tests]
  }
  
  /// Helper function to create the application target and the unit test target.
  private static func makeAppTargets(
    name: String,
    destinations: Destinations,
    dependencies: [TargetDependency],
    additionalSourcePaths: [String],
    additionalResourcePaths: [String]
  ) -> [Target] {
    let destinations: Destinations = destinations
    let infoPlist: [String: Plist.Value] = [
      "CFBundleShortVersionString": "1.0",
      "CFBundleVersion": "1",
      "UIMainStoryboardFile": "", // FIXME: SwiftUI로 개발해서 스토리보드는 지워도 될듯?
      "UILaunchStoryboardName": "LaunchScreen"
    ]
    
    let sources: SourceFilesList = {
      let globs: [SourceFileGlob] = {
        var returnValue: [SourceFileGlob] = []
        returnValue.append(SourceFileGlob.glob("Targets/\(name)/Sources/**"))
        for item in additionalSourcePaths {
          returnValue.append(.glob(
            Path(item)
          ))
        }
        return returnValue
      }()
      return SourceFilesList(globs: globs)
    }()
    
    let mainTarget = Target(
      name: name,
      destinations: destinations,
      product: .app,
      bundleId: "com.archive.networkSample\(name)",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .extendingDefault(with: infoPlist),
      sources: sources,
      resources: ["Targets/\(name)/Resources/**"],
      dependencies: dependencies
    )
    
    let testTarget = Target(
      name: "\(name)Tests",
      destinations: destinations,
      product: .uiTests,
      bundleId: "com.archive.\(name)Tests",
      infoPlist: .default,
      sources: ["Targets/\(name)/Tests/**"],
      dependencies: [
        .target(name: "\(name)")
      ])
    return [mainTarget, testTarget]
  }
}

public extension TargetDependency {
  static let moya: TargetDependency = .external(name: "Moya")
  static let combineMoya: TargetDependency = .external(name: "CombineMoya")
}
