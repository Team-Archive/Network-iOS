//
//  MultipartFromDataExtension.swift
//  Sample
//
//  Created by hanwe on 1/14/24.
//  Copyright © 2024 Archive. All rights reserved.
//

import Moya

extension MultipartFormData {
  func toMoyaData() -> Moya.MultipartFormData {
    let provider: Moya.MultipartFormData.FormDataProvider = {
      switch self.provider {
      case .data(let data):
        return .data(data)
      case .file(let url):
        return .file(url)
      case .stream(let stream, let value):
        return .stream(stream, value)
      }
    }()
    return .init(
      provider: provider,
      name: self.name,
      fileName: self.fileName,
      mimeType: self.mimeType
    )
  }
}
