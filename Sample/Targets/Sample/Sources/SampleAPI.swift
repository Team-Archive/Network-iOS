//
//  SampleAPI.swift
//  Sample
//
//  Created by hanwe on 1/14/24.
//  Copyright © 2024 Archive. All rights reserved.
//

import Foundation

enum SampleAPI {
  case search(keyword: String, offset: UInt, limit: UInt)
}

extension SampleAPI: TargetType {
  
  var baseURL: URL {
    return URL(string: "https://itunes.apple.com")!
  }
  
  var path: String {
    switch self {
    case .search:
      return "/search"
    }
  }
  
  var method: HTTPMethod {
    switch self {
    case .search:
      return .get
    }
  }
  
  var task: Task {
    switch self {
    case .search(let keyword, let offset, let limit):
      return .requestParameters(
        parameters: [
          "term": keyword,
          "entity": "software",
          "limit": limit,
          "offset": offset,
          "country": "KR",
          "media": "software"
        ],
        encoding: .urlEncoding)
    }
  }
  
  var headers: [String : String]? {
    return nil
  }
  
}
