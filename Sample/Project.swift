import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

// MARK: - Project

let project = Project.app(
  name: "Sample",
  destinations: .iOS,
  dependencies: [
    .moya,
    .combineMoya
  ],
  additionalTargets: [],
  additionalSourcePaths: ["../Sources/**"],
  additionalResourcePaths: []
)
