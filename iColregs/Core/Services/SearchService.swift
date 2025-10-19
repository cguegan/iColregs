//
//  SearchService.swift
//  iColregs
//
//  Created by Christophe Guégan on 26/10/2025.
//

import Foundation
import Observation

/// Observable search engine that encapsulates the shared search helpers and
/// exposes a ready-to-bind API for SwiftUI views.
/// - Note: This service is designed to be used as a singleton shared instance.
///
@Observable
final class SearchService {
  
  /// Localised configuration describing UI labels, section titles, etc.
  var configuration: PartSearchConfiguration {
    didSet { refreshResults() }
  }
  
  /// User-entered query string. Updating this property automatically refreshes results.
  var searchText: String = "" {
    didSet {
      guard oldValue != searchText else { return }
      refreshResults()
    }
  }
  
  /// Latest search results matching `searchText`.
  var results: [SearchResult] = []
  
  /// private stored properties
  private var ruleParts: [PartModel]
  private var annexParts: [PartModel]
  
  /// Designated initializer.
  /// - Parameters:
  ///   - configuration: Localised configuration describing titles/labels.
  ///   - ruleParts: Rule datasets to index.
  ///   - annexParts: Annex datasets to index.
  ///   - searchText: Optional initial query (defaults to empty).
  init(configuration: PartSearchConfiguration,
       ruleParts: [PartModel],
       annexParts: [PartModel],
       searchText: String = "") {
    self.configuration = configuration
    self.ruleParts = ruleParts
    self.annexParts = annexParts
    self.searchText = searchText
    refreshResults()
  }
  
  /// Updates configuration and underlying datasets, then re-runs the search using the current query.
  func update(configuration: PartSearchConfiguration,
              ruleParts: [PartModel],
              annexParts: [PartModel]) {
    self.configuration = configuration
    self.ruleParts = ruleParts
    self.annexParts = annexParts
    refreshResults()
  }
  
  /// Executes the search for the current `searchText` and publishes the resulting hits.
  func refreshResults() {
    let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      results = []
      return
    }
    
    var combined = performSearch(in: ruleParts,
                                 query: trimmed,
                                 detailTitle: configuration.ruleDetailTitle,
                                 source: .rule)
    combined += performSearch(in: annexParts,
                              query: trimmed,
                              detailTitle: configuration.articleDetailTitle,
                              source: .annex)
    results = combined
  }
  
}
