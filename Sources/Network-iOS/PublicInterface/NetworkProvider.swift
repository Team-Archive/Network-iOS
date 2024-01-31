//
//  NetworkProvider.swift
//
//
//  Created by hanwe on 1/7/24.
//

import Foundation
import Moya
import Alamofire
import CombineMoya
import Combine

protocol Networkable {
  associatedtype Target
  @available(macOS 10.15, *)
  func request(target: Target) -> AnyPublisher<Result<Data, Error>, Never>
}

public final class NetworkProvider<Target: TargetType> {
  
  
  // MARK: - private properties
  
  private let isStub: Bool
  private let sampleStatusCode: Int
  
  // MARK: - properties
  
  var provider: MoyaProvider<Target>
  let dispatchQueue = DispatchQueue(label: "queue.network.hw", qos: .default)
  
  let loggerPlugin = NetworkLoggerPlugin()
  
  let customEndpointClosure = { (target: Target) -> Endpoint in
    return Endpoint(
      url: URL(target: target).absoluteString,
      sampleResponseClosure: { .networkResponse(200, target.sampleData) },
      method: target.method,
      task: target.task,
      httpHeaderFields: target.headers
    )
  }
  
  // MARK: - life cycle
  
  public init(isStub: Bool = false, sampleStatusCode: Int = 200) {
    self.isStub = isStub
    self.sampleStatusCode = sampleStatusCode
    
    if isStub {
      self.provider = MoyaProvider<Target>(
        endpointClosure: customEndpointClosure,
        stubClosure: MoyaProvider.immediatelyStub,
        plugins: [loggerPlugin]
      )
    } else {
      self.provider = MoyaProvider<Target>(
        stubClosure: MoyaProvider.neverStub,
        callbackQueue: nil,
        session: AlamofireSession.configuration,
        plugins: [loggerPlugin]
      )
    }
  }
  
  deinit {
    print("network provider has deinited")
  }
}

@available(macOS 10.15, *)
extension NetworkProvider: Networkable {
  
  public func request(target: Target) -> AnyPublisher<Result<Data, Error>, Never> {
    return self.provider.requestPublisher(target)
      .map { response -> Result<Data, Error> in
        switch response.statusCode {
        case 200...299:
          return .success(response.data)
        default:
          return .failure(NSError(
            domain: "server",
            code: response.statusCode,
            userInfo: [
              NSLocalizedDescriptionKey: "Server Error"
            ]
          ))
        }
      }
      .catch({ err -> AnyPublisher<Result<Data, Error>, Never> in
        return Just(.failure(NSError(
          domain: "network",
          code: err.response?.statusCode ?? err.errorCode,
          userInfo: [
            NSLocalizedDescriptionKey: err.localizedDescription
          ]
        )))
        .eraseToAnyPublisher()
      })
      .eraseToAnyPublisher()
  }
  
}

class AlamofireSession: Alamofire.Session {
  
  static let configuration: Alamofire.Session = {
    let configuration = URLSessionConfiguration.default
    configuration.headers = HTTPHeaders.default
    configuration.timeoutIntervalForRequest = 60
    configuration.timeoutIntervalForResource = 60
    configuration.requestCachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
    
    return Alamofire.Session(configuration: configuration)
  }()
  
}
