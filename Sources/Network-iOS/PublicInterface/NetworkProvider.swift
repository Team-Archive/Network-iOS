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
//  func request(target: Target) -> Observable<Result<Data, HWError>>
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
//func transformPublisher(_ inputPublisher: AnyPublisher<Response, MoyaError>) -> AnyPublisher<Response, Error> {
//    return inputPublisher
//        .mapError { $0 as Error }
//        .eraseToAnyPublisher()
//}
//extension NetworkProvider: Networkable {
//  
//  func request(target: Target) -> Observable<Result<Data, HWError>> {
//    
//    guard !isStub else {
//      let stubRequest = self.provider.rx.request(target, callbackQueue: self.dispatchQueue)
//      if 200...299 ~= self.sampleStatusCode {
//        return stubRequest
//          .asObservable()
//          .map { response in
//            return .success(response.data)
//          }
//          .catch { error in
//            return .just(.failure(HWError.init(from: .server, code: error.toResponseCode, message: error.toHWNetworkErrorDescription)))
//          }
//      } else {
//        return .just(.failure(HWError.init(from: .server, code: self.sampleStatusCode, message: "sample error")))
//      }
//    }
//    
//    let online = networkEnable()
//    
//    switch providerType {
//    case .specificCatch(let successCodeRange):
//      return online
//        .take(1)
//        .flatMapLatest { isOnline in
//          guard isOnline else { return Single<Result<Data, HWError>>.just(.failure(.init(.internetIsNotConnected))) }
//          return self.provider.rx.request(target, callbackQueue: self.dispatchQueue)
//            .filter(statusCodes: successCodeRange)
//            .map { response in
//              return .success(response.data)
//            }
//        }
//    case .customCatchError:
//      return online
//        .take(1)
//        .flatMapLatest { isOnline in
//          guard isOnline else { return Single<Result<Data, HWError>>.just(.failure(.init(.internetIsNotConnected))) }
//          return self.provider.rx.request(target, callbackQueue: self.dispatchQueue)
//            .filterSuccessfulStatusCodes()
//            .map { response in
//              return .success(response.data)
//            }
//        }
//    case .normal:
//      return online
//        .take(1)
//        .flatMapLatest { isOnline in
//          guard isOnline else { return Single<Result<Data, HWError>>.just(.failure(.init(.internetIsNotConnected))) }
//          return self.provider.rx.request(target, callbackQueue: self.dispatchQueue)
//            .filterSuccessfulStatusCodes()
//            .map { response in
//              return .success(response.data)
//            }
//            .catch { error in
//              return .just(.failure(HWError.init(from: .server, code: error.toResponseCode, message: error.toHWNetworkErrorDescription)))
//            }
//        }
//    }
//  }
//}
//
//
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
//
//func networkEnable() -> Observable<Bool> {
//  ReachabilityManager.shared.reach
//}
//
//// MARK: - ReachabilityManager
//
//class ReachabilityManager: NSObject {
//  
//  static let shared = ReachabilityManager()
//  
//  let reachSubject = ReplaySubject<Bool>.create(bufferSize: 1)
//  var reach: Observable<Bool> {
//    reachSubject.asObservable()
//      .do(onNext: { reachable in
//        if !reachable {
//          print("네트워크에 연결할 수 없습니다.")
//        }
//      })
//  }
//  
//  override private init() {
//    super.init()
//    NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { status in
//      let reachable = (status == .notReachable || status == .unknown) ? false : true
//      self.reachSubject.onNext(reachable)
//    })
//  }
//}
