//
//  TargetType.swift
//
//
//  Created by hanwe on 1/7/24.
//

import Foundation
import Moya
import Alamofire

public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias URLEncoding = Alamofire.URLEncoding

public protocol TargetType: Moya.TargetType {
  
  /// The target's base `URL`.
  var baseURL: URL { get }
  
  /// The path to be appended to `baseURL` to form the full `URL`.
  var path: String { get }
  
  /// The HTTP method used in the request.
  var testmethod: HTTPMethod { get }
  
  /// Provides stub data for use in testing. Default is `Data()`.
  var sampleData: Data { get }
  
  /// The type of HTTP task to be performed.
  var testtask: Task { get }
  
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
  
  var method: Moya.Method {
    switch self.testmethod {
    case .connect:
      return .connect
    case .delete:
      return .delete
    case .get:
      return .get
    case .head:
      return .head
    case .options:
      return .options
    case .patch:
      return .patch
    case .post:
      return .post
    case .put:
      return .put
    case .query:
      return .query
    case .trace:
      return .trace
    default:
      return .post
    }
  }
  
  var task: Moya.Task {
    switch self.testtask {
    case .requestPlain:
      return .requestPlain
    case .requestData(let data):
      return .requestData(data)
    case .requestJSONEncodable(let encodable):
      return .requestJSONEncodable(encodable)
    case .requestCustomJSONEncodable(let encodable, let encoder):
      return .requestCustomJSONEncodable(encodable, encoder: encoder)
    case .requestParameters(let parameters, let encodingType):
      let encoding: ParameterEncoding = {
        switch encodingType {
        case .jsonEncoding:
          return JSONEncoding.default
        case .urlEncoding:
          return URLEncoding.default
        }
      }()
      return .requestParameters(parameters: parameters, encoding: encoding)
    case .requestCompositeData(let bodyData, let urlParameters):
      return .requestCompositeData(bodyData: bodyData, urlParameters: urlParameters)
    case .requestCompositeParameters(let bodyParameters, let encodingType,  let urlParameters):
      let encoding: ParameterEncoding = {
        switch encodingType {
        case .jsonEncoding:
          return JSONEncoding.default
        case .urlEncoding:
          return URLEncoding.default
        }
      }()
      return .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: encoding, urlParameters: urlParameters)
    case .uploadFile(let url):
      return .uploadFile(url)
    case .uploadMultipart(let dataList):
      return .uploadMultipart(dataList.map { $0.toMoyaData() })
    case .uploadCompositeMultipart(let dataList, let urlParameters):
      return .uploadCompositeMultipart(dataList.map { $0.toMoyaData() }, urlParameters: urlParameters)
    }
  }
  
}
