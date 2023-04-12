//
//  FileManager+Sth.swift
//  NeatGallery
//
//  Created by Farhad Bagherzadeh on 11/4/2023.
//

import Foundation

extension FileManager {
  func getFolderURLsInDirectory(
    atURL url: URL,
    sortedBy: ContentDate,
    ascending: Bool = true,
    options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
  ) throws -> [URL]? {

    let key: URLResourceKey = sortedBy.resourceKey
    var urls: [URL] = try contentsOfDirectory(at: url, includingPropertiesForKeys: [key, .isDirectoryKey], options: options)

    try urls.sort {
      let values1 = try $0.resourceValues(forKeys: [key])
      let values2 = try $1.resourceValues(forKeys: [key])

      if let date1 = values1.allValues.first?.value as? Date,
         let date2 = values2.allValues.first?.value as? Date {
        return date1.compare(date2) == (ascending ? .orderedAscending : .orderedDescending)
      }
      return true
    }

    return urls
  }
}
