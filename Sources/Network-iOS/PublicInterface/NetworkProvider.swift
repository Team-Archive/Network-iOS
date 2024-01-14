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
  func request(target: Target) -> AnyPublisher<Response, Error>
}

final class NetworkProvider<Target: TargetType> {
  
  
  // MARK: - private properties
  
  private let isStub: Bool
  private let providerType: ProviderType
  private let sampleStatusCode: Int
  
  // MARK: - properties
  
  var provider: MoyaProvider<Target>
  let dispatchQueue = DispatchQueue(label: "queue.network.hw", qos: .default)
  
  let loggerPlugin = NetworkLoggerPlugin()
  
  enum ProviderType {
    case specificCatch(successCodeRange: ClosedRange<Int>)
    case customCatchError
    case normal
  }
  
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
  
  init(isStub: Bool = false, sampleStatusCode: Int = 200, providerType: ProviderType = .normal) {
    self.isStub = isStub
    self.providerType = providerType
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
  func request(target: Target) -> AnyPublisher<Response, Error> {
    return self.provider.requestPublisher(target)
      .mapError { $0 as Error }
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
