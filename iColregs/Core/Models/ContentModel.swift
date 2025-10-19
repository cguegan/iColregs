//
//  ContentModel.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import Foundation
import SwiftUI

struct ContentModel: Identifiable, Decodable {
  let id: UUID
  let indent: String
  let text: String
  let image: String?
  
  init(indent: String,
       text: String,
       image: String?,
       id: UUID = UUID()) {
    self.id = id
    self.indent = indent
    self.text = text
    self.image = image
  }
  
  private enum CodingKeys: String, CodingKey {
    case indent
    case text
    case image
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    indent = try container.decode(String.self, forKey: .indent)
    text = try container.decode(String.self, forKey: .text)
    image = try container.decodeIfPresent(String.self, forKey: .image)
    id = UUID()
  }
  
  /// Returns the localized string key for the text content.
  var content: LocalizedStringKey {
    return LocalizedStringKey(text)
  }
  
  /// Returns the levels of indentation based on the indent string.
  var levels: String {
    
    var currentLevel = ""
    
    for level in indent.components(separatedBy: "_") {
      // Paragraph
      if level == "p" {
        return ""
        // Add
      } else if level != "" && level != "•" {
        currentLevel = currentLevel + "(\(level))\t"
      } else if level == "•" {
        // Add
        currentLevel = currentLevel + "\(level)"
      } else {
        // Add tab if -
        currentLevel = currentLevel + "\t"
      }
    }
    
    return currentLevel
    
  }
}
