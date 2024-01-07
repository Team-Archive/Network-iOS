//
//  ParameterEncoding.swift
//  
//
//  Created by hanwe on 1/7/24.
//

import Foundation

/// A dictionary of parameters to apply to a `URLRequest`.
public typealias Parameters = [String: Any]

/// A type used to define how a set of parameters are applied to a `URLRequest`.
public protocol ParameterEncoding {
  /// Creates a `URLRequest` by encoding parameters and applying them on the passed request.
  ///
  /// - Parameters:
  ///   - urlRequest: `URLRequestConvertible` value onto which parameters will be encoded.
  ///   - parameters: `Parameters` to encode onto the request.
  ///
  /// - Returns:      The encoded `URLRequest`.
  /// - Throws:       Any `Error` produced during parameter encoding.
  func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest
}

/// Types adopting the `URLRequestConvertible` protocol can be used to safely construct `URLRequest`s.
public protocol URLRequestConvertible {
  /// Returns a `URLRequest` or throws if an `Error` was encountered.
  ///
  /// - Returns: A `URLRequest`.
  /// - Throws:  Any error thrown while constructing the `URLRequest`.
  func asURLRequest() throws -> URLRequest
}
