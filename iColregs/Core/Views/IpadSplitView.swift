//
//  IpadSplitView.swift
//  iColregs
//
//  Created by Christophe Guégan on 15/10/2025.
//

import SwiftUI
import Observation

struct IpadSplitView: View {
  
  /// Environment Properties
  @Environment(AppService.self) private var appService
  
  /// State Properties
  @State private var language: Language = .en
  @State private var searchModel: SearchViewModel
  @State private var expansionModel: SidebarExpansionViewModel
  
  init() {
    _searchModel = State(initialValue: SearchViewModel(language: .en))
    _expansionModel = State(initialValue: SidebarExpansionViewModel(language: .en))
  }
  
  /// Computed Properties
  private var configuration: PartSearchConfiguration {
    searchModel.configuration
  }
  private var rulesDataset:       [PartModel] { appService.datasets(for: language).rules }
  private var annexDataset:       [PartModel] { appService.datasets(for: language).annexes }
  private var searchResults:      [SearchResult] {
    searchModel.results
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
      syncModels()
    }
    .onChange(of: language) { _, newValue in
      searchModel.clearQuery()
      syncModels(for: newValue)
    }
    .onChange(of: rulesDataset.map(\.id)) { _, _ in syncModels() }
    .onChange(of: annexDataset.map(\.id)) { _, _ in syncModels() }
  }
  
}


// MARK: - Sidebar Views
// —————————————————————

extension IpadSplitView {

  /// Sidebar List View
  ///
  @ViewBuilder
  private var sidebarList: some View {
    @Bindable var binding = searchModel.service
    List {
      if let query = searchModel.trimmedQuery {
        searchResultsSection(query: query)
      } else {
        localizedSidebarList
        aboutSection
      }
    }
    .listStyle(.sidebar)
    .searchable( text: $binding.searchText,
                 placement: .sidebar,
                 prompt: Text(configuration.searchPlaceholder) )
  }
  
  private struct SidebarStrings {
    let emptyMessage: String
    let rulesHeader: String
    let annexHeader: String
  }

  private var sidebarStrings: SidebarStrings {
    switch language {
    case .en:
      return SidebarStrings(emptyMessage: "Error…",
                            rulesHeader: "Rules",
                            annexHeader: "Annexes")
    case .fr:
      return SidebarStrings(emptyMessage: "Erreur…",
                            rulesHeader: "Règles",
                            annexHeader: "Annexes")
    }
  }

  /// Localised Colregs/RIPAM List
  ///
  @ViewBuilder
  private var localizedSidebarList: some View {
    let rules = searchModel.ruleParts
    let annexes = searchModel.annexParts
    let strings = sidebarStrings

    if rules.isEmpty && annexes.isEmpty {
      Text(strings.emptyMessage)
        .foregroundStyle(.secondary)
    } else {
      if !rules.isEmpty {
        sidebarSeparator(title: strings.rulesHeader)
        partList(for: rules, ruleLabel: configuration.ruleDetailTitle)
      }

      if !annexes.isEmpty {
        sidebarSeparator(title: strings.annexHeader)
        partList(for: annexes, ruleLabel: configuration.articleDetailTitle)
      }
    }
  }
  
  /// Search Results Section
  ///
  @ViewBuilder
  private func searchResultsSection(query: String) -> some View {
    Section(configuration.resultsTitle) {
      if searchResults.isEmpty {
        Text(configuration.noResultsMessage)
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
  
  /// Search Result Row View
  ///
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
        Text("\(result.matchCount) \(configuration.matchLabel(result.matchCount))")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 6)
  }

  /// Part List View
  ///
  @ViewBuilder
  func partList(for parts: [PartModel], ruleLabel: String) -> some View {
    @Bindable var expansionBinding = expansionModel
    ForEach(parts) { part in
      Section(
        part.title,
        isExpanded: Binding(
          get: { expansionBinding.isPartExpanded(part.id) },
          set: { newValue in
            expansionBinding.togglePart(part.id,
                                         isExpanded: newValue,
                                         language: language)
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
  
  /// About Section
  ///
  @ViewBuilder
  var aboutSection: some View {
    sidebarSeparator(title: language == .en ? "Information" : "Informations")
    NavigationLink {
      AboutView()
    } label: {
      Label("About iColregs", systemImage: "info.circle")
    }
  }
  
  /// Sidebar Separator View
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
  
  /// Rule Row View
  /// - Parameters:
  ///  - rule: RuleModel
  ///  - detailTitle: Detail Title
  ///  - highlightTerm: Highlight Term (optional)
  /// - Returns: some View
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
  
}


// MARK: - Private Methods
// ———————————————————————

private extension IpadSplitView {
  
  /// Data for Language
  /// - Parameter language: Language
  /// - Returns: Tuple of rules and annexes PartModel arrays
  ///
  /// Sync Models for Language
  /// - Parameter language: Language (optional)
  /// - Returns: Void
  ///
  func syncModels(for language: Language? = nil) {
    let activeLanguage = language ?? self.language
    let datasets = appService.datasets(for: activeLanguage)
    searchModel.setLanguage(activeLanguage,
                            ruleParts: datasets.rules,
                            annexParts: datasets.annexes)
    expansionModel.reload(for: activeLanguage)
  }
  
  /// Sync Models
  /// - Returns: Void
  ///
  func syncModels() {
    syncModels(for: language)
  }
  
  /// Binding for Section Expansion
  /// - Parameters:
  ///  - partID: Part ID
  ///  - sectionID: Section ID
  /// - Returns: Binding<Bool>
  ///
  func bindingForSection(partID: String,
                         sectionID: String) -> Binding<Bool> {
    Binding(
      get: {
        expansionModel.isSectionExpanded(partID: partID, sectionID: sectionID)
      },
      set: { newValue in
        expansionModel.toggleSection(partID: partID,
                                     sectionID: sectionID,
                                     isExpanded: newValue,
                                     language: language)
      }
    )
  }
  

}


// MARK: - Preview
// —————————————-—

#Preview {
  IpadSplitView()
    .environment(AppService())
}
