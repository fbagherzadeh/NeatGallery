//
//  FileManager+ContentDate.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 11/4/2023.
//

import Foundation
extension FileManager {
  enum ContentDate {
    case created, modified, accessed

    var resourceKey: URLResourceKey {
      switch self {
      case .created: return .creationDateKey
      case .modified: return .contentModificationDateKey
      case .accessed: return .contentAccessDateKey
      }
    }
  }
}
