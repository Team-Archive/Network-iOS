//
//  TargetType.swift
//
//
//  Created by hanwe on 1/7/24.
//

import Foundation
import Moya

public protocol TargetType: Moya.TargetType {
  
  /// The target's base `URL`.
  var baseURL: URL { get }
  
  /// The path to be appended to `baseURL` to form the full `URL`.
  var path: String { get }
  
  /// The HTTP method used in the request.
  var method: HTTPMethod { get }
  
  /// Provides stub data for use in testing. Default is `Data()`.
  var sampleData: Data { get }
  
  /// The type of HTTP task to be performed.
  var task: Task { get }
  
  /// The type of validation to perform on the request. Default is `.none`.
  var validationType: ValidationType { get }
  
  /// The headers to be used in the request.
  var headers: [String: String]? { get }
}

public extension TargetType {
  
  /// The type of validation to perform on the request. Default is `.none`.
  var validationType: ValidationType { .none }
  
  /// Provides stub data for use in testing. Default is `Data()`.
  var sampleData: Data { Data() }
  
}
