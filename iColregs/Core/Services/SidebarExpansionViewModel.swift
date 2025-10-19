//
//  SidebarExpansionViewModel.swift
//  iColregs
//
//  Created by ChatGPT on 27/10/2025.
//

import Foundation
import Observation

/// Observable view model used by the iPad split view to track which parts/sections
/// are expanded per language. Persists state using UserDefaults-backed raw strings.
/// 
@Observable
final class SidebarExpansionViewModel {
  private enum StorageKeys {
    static func parts(_ language: Language) -> String {
      "IpadSplitView.expandedParts.\(language.rawValue.lowercased())"
    }
    static func sections(_ language: Language) -> String {
      "IpadSplitView.expandedSections.\(language.rawValue.lowercased())"
    }
  }
  
  private(set) var expandedParts: Set<String>
  private(set) var expandedSections: [String: Set<String>]
  
  private let defaults: UserDefaults
  
  init(language: Language,
       defaults: UserDefaults = .standard) {
    self.defaults = defaults
    expandedParts = Self.decodeSet(from: defaults.string(forKey: StorageKeys.parts(language)) ?? "[]")
    expandedSections = Self.decodeSections(from: defaults.string(forKey: StorageKeys.sections(language)) ?? "{}")
  }
  
  func togglePart(_ partID: String, isExpanded: Bool, language: Language) {
    if isExpanded {
      expandedParts.insert(partID)
    } else {
      expandedParts.remove(partID)
      expandedSections[partID] = nil
    }
    persist(language: language)
  }
  
  func toggleSection(partID: String,
                     sectionID: String,
                     isExpanded: Bool,
                     language: Language) {
    var sectionSet = expandedSections[partID] ?? []
    if isExpanded {
      sectionSet.insert(sectionID)
    } else {
      sectionSet.remove(sectionID)
    }
    expandedSections[partID] = sectionSet.isEmpty ? nil : sectionSet
    persist(language: language)
  }
  
  func isPartExpanded(_ partID: String) -> Bool {
    expandedParts.contains(partID)
  }
  
  func isSectionExpanded(partID: String, sectionID: String) -> Bool {
    expandedSections[partID, default: []].contains(sectionID)
  }
  
  func reload(for language: Language) {
    expandedParts = Self.decodeSet(from: defaults.string(forKey: StorageKeys.parts(language)) ?? "[]")
    expandedSections = Self.decodeSections(from: defaults.string(forKey: StorageKeys.sections(language)) ?? "{}")
  }
  
  // MARK: - Persistence helpers
  
  private func persist(language: Language) {
    defaults.set(Self.encodeSet(expandedParts), forKey: StorageKeys.parts(language))
    defaults.set(Self.encodeSections(expandedSections), forKey: StorageKeys.sections(language))
  }
  
  private static func encodeSet(_ set: Set<String>) -> String {
    guard let data = try? JSONEncoder().encode(Array(set)),
          let string = String(data: data, encoding: .utf8) else {
      return "[]"
    }
    return string
  }
  
  private static func decodeSet(from raw: String) -> Set<String> {
    guard let data = raw.data(using: .utf8),
          let array = try? JSONDecoder().decode([String].self, from: data) else {
      return []
    }
    return Set(array)
  }
  
  private static func encodeSections(_ sections: [String: Set<String>]) -> String {
    let dictionary = sections.mapValues { Array($0) }
    guard let data = try? JSONEncoder().encode(dictionary),
          let string = String(data: data, encoding: .utf8) else {
      return "{}"
    }
    return string
  }
  
  private static func decodeSections(from raw: String) -> [String: Set<String>] {
    guard let data = raw.data(using: .utf8),
          let dictionary = try? JSONDecoder().decode([String: [String]].self, from: data) else {
      return [:]
    }
    return dictionary.mapValues { Set($0) }
  }
}
