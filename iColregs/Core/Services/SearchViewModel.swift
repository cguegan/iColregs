//
//  SearchViewModel.swift
//  iColregs
//
//  Created by ChatGPT on 27/10/2025.
//

import Foundation
import Observation

/// Observable view model that wraps `SearchService` to provide language-aware configuration
/// and dataset management for search-driven views.
@Observable
final class SearchViewModel {
  
  /// Current language used to configure search labels and datasets.
  private(set) var language: Language
  
  /// Current configuration derived from the selected language.
  private(set) var configuration: PartSearchConfiguration
  
  /// Latest rule parts supplied to the search engine.
  private(set) var ruleParts: [PartModel]
  
  /// Latest annex parts supplied to the search engine.
  private(set) var annexParts: [PartModel]
  
  /// Underlying search service bound to SwiftUI.
  let service: SearchService
  
  /// Convenience accessor for the trimmed query text.
  var trimmedQuery: String? {
    let trimmed = service.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
  
  /// Current search results.
  var results: [SearchResult] {
    service.results
  }
  
  /// Designated initializer.
  /// - Parameters:
  ///   - language: Initial language to configure the search.
  ///   - ruleParts: Initial rule dataset.
  ///   - annexParts: Initial annex dataset.
  ///   - searchText: Initial search query.
  ///
  init(language: Language,
       ruleParts: [PartModel] = [],
       annexParts: [PartModel] = [],
       searchText: String = "") {
    self.language = language
    let configuration = PartSearchConfiguration.forLanguage(language)
    self.configuration = configuration
    self.ruleParts = ruleParts
    self.annexParts = annexParts
    self.service = SearchService(configuration: configuration,
                                 ruleParts: ruleParts,
                                 annexParts: annexParts,
                                 searchText: searchText)
  }
  
  /// Updates the datasets feeding the search engine.
  /// - Parameters:
  ///   - ruleParts: Updated rule dataset.
  ///   - annexParts: Updated annex dataset.
  ///
  func updateDatasets(ruleParts: [PartModel],
                      annexParts: [PartModel]) {
    self.ruleParts = ruleParts
    self.annexParts = annexParts
    service.update(configuration: configuration,
                   ruleParts: ruleParts,
                   annexParts: annexParts)
  }
  
  /// Switches language and updates configuration and datasets accordingly.
  /// - Parameters:
  ///   - language: The target language.
  ///   - ruleParts: Rule dataset for the language.
  ///   - annexParts: Annex dataset for the language.
  func setLanguage(_ language: Language,
                   ruleParts: [PartModel],
                   annexParts: [PartModel]) {
    guard self.language != language else {
      updateDatasets(ruleParts: ruleParts, annexParts: annexParts)
      return
    }
    
    self.language = language
    configuration = PartSearchConfiguration.forLanguage(language)
    updateDatasets(ruleParts: ruleParts, annexParts: annexParts)
  }
  
  /// Resets the current query.
  func clearQuery() {
    service.searchText = ""
  }
}
