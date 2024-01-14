//
//  Dependencies.swift
//  Config
//
//  Created by Aaron Hanwe LEE on 2022/08/10.
//


import ProjectDescription

let dependencies = Dependencies(
  carthage: nil,
  swiftPackageManager: SwiftPackageManagerDependencies(
    [
      .remote(url: "https://github.com/HanweeeeLee/Moya.git", requirement: .branch("master"))
    ],
    productTypes: [
      "Moya": .staticFramework
    ],
    baseSettings: .settings(
      configurations: [
        .debug(name: .debug),
        .release(name: .release),
      ]
    ),
    targetSettings: [:]
  ),
  platforms: [.iOS]
)
