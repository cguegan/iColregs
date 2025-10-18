//
//  IpadSplitView.swift
//  iColregs
//
//  Created by Christophe Guégan on 15/10/2025.
//

import SwiftUI

struct IpadSplitView: View {
  
  /// Environment Properties
  @Environment(AppService.self) private var appService
  
  /// State Properties
  @State private var language: Language = .en
  @State private var searchText: String = ""
  @State private var expandedParts: Set<String> = []
  @State private var expandedSections: [String: Set<String>] = [:]
  
  /// Stored Properties
  @AppStorage("IpadSplitView.expandedParts.en") private var storedExpandedPartsEN: String = "[]"
  @AppStorage("IpadSplitView.expandedParts.fr") private var storedExpandedPartsFR: String = "[]"
  @AppStorage("IpadSplitView.expandedSections.en") private var storedExpandedSectionsEN: String = "{}"
  @AppStorage("IpadSplitView.expandedSections.fr") private var storedExpandedSectionsFR: String = "{}"
  
  /// Computed Properties
  private var searchQuery:        String? {
    let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
  private var ruleDetailTitle:    String {
    language == .en ? "Rule" : "Règle"
  }
  private var articleDetailTitle: String {
    "Article"
  }
  private var searchPlaceholder:  String {
    language == .en ? "Search Colregs" : "Rechercher RIPAM"
  }
  private var noResultsMessage:   String {
    language == .en ? "No matches found" : "Aucun résultat"
  }
  private var rulesDataset:       [PartModel] {
    switch language {
    case .en:
      return appService.colregs?.colregs ?? []
    case .fr:
      return appService.ripam?.ripam ?? []
    }
  }
  private var annexDataset:       [PartModel] {
    switch language {
    case .en:
      return appService.annexesEn?.colregs ?? []
    case .fr:
      return appService.annexesFr?.ripam ?? []
    }
  }
  private var searchResults:      [SearchResult] {
    guard let query = searchQuery else { return [] }
    var results = performSearch(in: rulesDataset,
                                query: query,
                                detailTitle: ruleDetailTitle,
                                source: .rule)
    results += performSearch(in: annexDataset,
                             query: query,
                             detailTitle: articleDetailTitle,
                             source: .annex)
    return results
  }
  
  /// Main Body View
  var body: some View {
    NavigationSplitView {
      // Picker
      Picker("Select Language", selection: $language) {
        ForEach(Language.allCases, id: \.self) { lang in
          Text(lang.rawValue).tag(lang)
        }
      }
      .pickerStyle(.segmented)
      .padding()
      
      // List
      sidebarList
        .navigationTitle(language == .en ? "Colregs" : "RIPAM" )
      
    } detail: {
      // Detail column
      Text("Select an option from the sidebar")
        .foregroundStyle(.secondary)
    }
    .onAppear {
      loadExpansionState(for: language)
    }
    .onChange(of: language) { oldValue, newValue in
      saveExpansionState(for: oldValue,
                         parts: expandedParts,
                         sections: expandedSections)
      loadExpansionState(for: newValue)
      searchText = ""
    }
  }
  
}


// MARK: - Sidebar Views
// —————————————————————

extension IpadSplitView {

  // MARK: - Sidebar List View
  // —————————————————————————
  @ViewBuilder
  private var sidebarList: some View {
    List {
      if let query = searchQuery {
        searchResultsSection(query: query)
      } else {
        switch language {
        case .en:
          englishColregsList
        case .fr:
          frenchRipamList
        }
      }
      aboutSection
    }
    .listStyle(.sidebar)
    .searchable(text: $searchText,
                placement: .sidebar,
                prompt: Text(searchPlaceholder))
  }
  
  
  // MARK: - English Colregs List
  // ———————————————————————————}
  @ViewBuilder
  private var englishColregsList: some View {
    let rules = appService.colregs?.colregs ?? []
    let annexes = appService.annexesEn?.colregs ?? []
    
    if rules.isEmpty && annexes.isEmpty {
      Text("Error…")
        .foregroundStyle(.secondary)
    } else {
      if !rules.isEmpty {
        sidebarSeparator(title: "Rules")
        partList(for: rules, ruleLabel: "Rule")
      }
      
      if !annexes.isEmpty {
        sidebarSeparator(title: "Annexes")
        partList(for: annexes, ruleLabel: "Article")
      }
    }
  }
  
  
  // MARK: - French Ripam List
  // —————————————————————————
  @ViewBuilder
  private var frenchRipamList: some View {
    let rules = appService.ripam?.ripam ?? []
    let annexes = appService.annexesFr?.ripam ?? []
    
    if rules.isEmpty && annexes.isEmpty {
      Text("Erreur…")
        .foregroundStyle(.secondary)
    } else {
      if !rules.isEmpty {
        sidebarSeparator(title: "Règles")
        partList(for: rules, ruleLabel: "Règle")
      }
      
      if !annexes.isEmpty {
        sidebarSeparator(title: "Annexes")
        partList(for: annexes, ruleLabel: "Article")
      }
    }
  }
  
  
  // MARK: - Search Results Section
  // ——————————————————————————————
  
  @ViewBuilder
  private func searchResultsSection(query: String) -> some View {
    Section(language == .en ? "Results" : "Résultats") {
      if searchResults.isEmpty {
        Text(noResultsMessage)
          .foregroundStyle(.secondary)
      } else {
        ForEach(searchResults) { result in
          NavigationLink {
            RuleView(rule: result.rule,
                     title: result.detailTitle,
                     highlightTerm: query)
          } label: {
            searchResultRow(result: result, query: query)
          }
        }
      }
    }
  }
  
  
  // MARK: - Search Result Row View
  // ——————————————————————————————
  
  @ViewBuilder
  private func searchResultRow(result: SearchResult, query: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: "\(result.rule.id).square.fill")
        .font(.title3)
        .foregroundStyle(result.source == .annex ? Color.orange : Color.accentColor)
        .accessibilityHidden(true)
        .padding(.top, 2)
      VStack(alignment: .leading, spacing: 4) {
        Text(result.displayTitle)
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(.primary)
          .lineLimit(2)
        Text(result.contextDescription)
          .font(.caption)
          .foregroundStyle(.secondary)
        markdownHighlightedText(result.snippet, query: query)
          .font(.footnote)
          .foregroundStyle(.secondary)
        Text("\(result.matchCount) \(matchLabel(for: result.matchCount))")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 6)
  }

  
  // MARK: - Part List View
  // ——————————————————————
  
  @ViewBuilder
  func partList(for parts: [PartModel], ruleLabel: String) -> some View {
    ForEach(parts) { part in
      Section(
        part.title,
        isExpanded: Binding(
          get: { expandedParts.contains(part.id) },
          set: { newValue in
            updatePartExpansion(partID: part.id, isExpanded: newValue)
          }
        )
      ) {
        ForEach(part.sections) { partSection in
          if partSection.title.isEmpty {
            ForEach(partSection.rules) { rule in
              ruleRow(rule: rule, detailTitle: ruleLabel)
            }
          } else {
            DisclosureGroup(
              isExpanded: bindingForSection(partID: part.id,
                                            sectionID: partSection.id)
            ) {
              ForEach(partSection.rules) { rule in
                ruleRow(rule: rule, detailTitle: ruleLabel)
              }
            } label: {
              Text(partSection.title.uppercased())
                .font(.caption.weight(.semibold))
                .font(.body.width(.compressed))
                .padding(.vertical, 0)
            }
          }
        }
      }
    }
  }
  
  
  // MARK: - About Section
  // —————————————————————
  
  @ViewBuilder
  var aboutSection: some View {
    Section(language == .en ? "Information" : "Informations") {
      NavigationLink {
        AboutView()
      } label: {
        Label("About iColregs", systemImage: "info.circle")
      }
    }
  }
  
  
  // MARK: - Sidebar Separator View
  // ——————————————————————————————
  
  @ViewBuilder
  func sidebarSeparator(title: String) -> some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title.uppercased())
        .font(.callout.weight(.semibold))
        .padding(.horizontal, 4)
        .padding(.top, 8)
      Divider()
    }
  }
}


// MARK: - Helpers
private extension IpadSplitView {
  
  /// Match Label Helper
  /// - Parameter count: The match count
  /// - Returns: The appropriate label for the match count
  ///
  private func matchLabel(for count: Int) -> String {
    if language == .en {
      return count == 1 ? "match" : "matches"
    } else {
      return count > 1 ? "occurrences" : "occurrence"
    }
  }
  
  /// Section Expansion Binding
  /// - Parameters:
  ///   - partID: The part ID
  ///   - sectionID: The section ID
  /// - Returns: A Binding<Bool> for the section expansion state
  ///
  func bindingForSection(partID: String,
                         sectionID: String) -> Binding<Bool> {
    Binding(
      get: {
        expandedSections[partID, default: []].contains(sectionID)
      },
      set: { newValue in
        updateSectionExpansion(partID: partID,
                               sectionID: sectionID,
                               isExpanded: newValue)
      }
    )
  }
  
  /// Rule Row View
  /// - Parameters:
  ///  - rule: The rule model
  ///  - detailTitle: The detail title
  ///  - highlightTerm: The term to highlight
  /// - Returns: A View for the rule row
  ///
  @ViewBuilder
  func ruleRow(rule: RuleModel,
               detailTitle: String,
               highlightTerm: String? = nil) -> some View {
    NavigationLink {
      RuleView(rule: rule,
               title: detailTitle,
               highlightTerm: highlightTerm)
    } label: {
      HStack(alignment: .firstTextBaseline, spacing: 8) {
        Image(systemName: "\(rule.id).square.fill")
          .font(.title)
          .foregroundStyle(.accent)
        Text(rule.title)
          .lineLimit(2)
          .offset(y: -4)
      }
    }
  }
  
  /// Expansion State Management
  /// - Parameters:
  ///  - partID: The part ID
  ///  - isExpanded: The expansion state
  /// - Returns: Void
  ///
  func updatePartExpansion( partID: String,
                            isExpanded: Bool ) {
    if isExpanded {
      expandedParts.insert(partID)
    } else {
      expandedParts.remove(partID)
      expandedSections[partID] = nil
    }
    persistCurrentExpansionState()
  }
  
  /// Expansion State Management
  /// - Parameters:
  ///  - partID: The part ID
  ///  - sectionID: The section ID
  ///  - isExpanded: The expansion state
  /// - Returns: Void
  ///
  func updateSectionExpansion( partID: String,
                               sectionID: String,
                               isExpanded: Bool ) {
    var partSet = expandedSections[partID] ?? []
    if isExpanded {
      partSet.insert(sectionID)
    } else {
      partSet.remove(sectionID)
    }
    expandedSections[partID] = partSet.isEmpty ? nil : partSet
    persistCurrentExpansionState()
  }
  
  /// Persistence of Expansion State
  /// - Returns: Void
  ///
  func persistCurrentExpansionState() {
    saveExpansionState(for: language,
                       parts: expandedParts,
                       sections: expandedSections)
  }
  
  /// Load Expansion State
  /// - Parameter language: The current language
  /// - Returns: Void
  ///
  func loadExpansionState(for language: Language) {
    expandedParts = decodeSet(from: rawParts(for: language))
    expandedSections = decodeSections(from: rawSections(for: language))
  }
  
  /// Save Expansion State
  /// - Parameters:
  ///  - language: The current language
  ///  - parts: The expanded parts
  ///  - sections: The expanded sections
  /// - Returns: Void
  ///
  func saveExpansionState( for language: Language,
                           parts: Set<String>,
                           sections: [String: Set<String>]) {
    setRawParts(encodeSet(parts), for: language)
    setRawSections(encodeSections(sections), for: language)
  }
  
  /// Raw Parts Getter/Setter
  /// - Parameter language: The current language
  /// - Returns: The raw stored parts string
  ///
  func rawParts(for language: Language) -> String {
    switch language {
    case .en:
      return storedExpandedPartsEN
    case .fr:
      return storedExpandedPartsFR
    }
  }
  
  /// Raw Parts Setter
  /// - Parameters:
  ///  - value: The raw string value
  ///  - language: The current language
  /// - Returns: Void
  ///
  func setRawParts( _ value: String,
                    for language: Language ) {
    switch language {
    case .en:
      storedExpandedPartsEN = value
    case .fr:
      storedExpandedPartsFR = value
    }
  }
  
  /// Raw Sections Getter/Setter
  /// - Parameter language: The current language
  /// - Returns: The raw stored sections string
  ///
  func rawSections(for language: Language) -> String {
    switch language {
    case .en:
      return storedExpandedSectionsEN
    case .fr:
      return storedExpandedSectionsFR
    }
  }
  
  /// Raw Sections Setter
  /// - Parameters:
  ///  - value: The raw string value
  ///  - language: The current language
  /// - Returns: Void
  ///
  func setRawSections( _ value: String,
                       for language: Language ) {
    switch language {
    case .en:
      storedExpandedSectionsEN = value
    case .fr:
      storedExpandedSectionsFR = value
    }
  }
  
  /// Encoding/Decoding Helpers
  /// - Parameter set: The set to encode
  /// - Returns: The encoded string
  ///
  func encodeSet(_ set: Set<String>) -> String {
    let array = Array(set)
    guard let data = try? JSONEncoder().encode(array),
          let string = String(data: data, encoding: .utf8) else {
      return "[]"
    }
    return string
  }
  
  /// Decoding Helper
  /// - Parameter raw: The raw string to decode
  /// - Returns: The decoded set
  ///
  func decodeSet(from raw: String) -> Set<String> {
    guard let data = raw.data(using: .utf8),
          let array = try? JSONDecoder().decode([String].self, from: data) else {
      return []
    }
    return Set(array)
  }
  
  /// Encoding/Decoding Helpers
  /// - Parameter sections: The sections to encode
  /// - Returns: The encoded string
  ///
  func encodeSections(_ sections: [String: Set<String>]) -> String {
    let dictionary = sections.mapValues { Array($0) }
    guard let data = try? JSONEncoder().encode(dictionary),
          let string = String(data: data, encoding: .utf8) else {
      return "{}"
    }
    return string
  }
  
  /// Decoding Helper
  /// - Parameter raw: The raw string to decode
  /// - Returns: The decoded sections
  ///
  func decodeSections(from raw: String) -> [String: Set<String>] {
    guard let data = raw.data(using: .utf8),
          let dictionary = try? JSONDecoder().decode([String: [String]].self, from: data) else {
      return [:]
    }
    return dictionary.mapValues { Set($0) }
  }
  
}


// MARK: - Preview
// —————————————-—

#Preview {
  IpadSplitView()
    .environment(AppService())
}
