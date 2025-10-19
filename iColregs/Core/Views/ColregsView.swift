//
//  ColregsView.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import SwiftUI
import Observation

struct ColregsView: View {
  let language: Language
  
  @Environment(AppService.self) private var appService
  @Environment(\.colorScheme) private var colorScheme
  @State private var searchService: SearchService
  
  init(language: Language = .en) {
    self.language = language
    let initialConfig = ColregsView.configuration(for: language)
    _searchService = State(initialValue: SearchService(configuration: initialConfig,
                                                       ruleParts: [],
                                                       annexParts: []))
  }
  
  private static func configuration(for language: Language) -> PartSearchConfiguration {
    switch language {
    case .en:
      return PartSearchConfiguration(
        resultsTitle: "Results",
        noResultsMessage: "No matches found",
        searchPlaceholder: "Search Colregs",
        rulesSectionTitle: "Colregs",
        ruleDetailTitle: "Rule",
        articleDetailTitle: "Article",
        matchLabel: { $0 == 1 ? "match" : "matches" }
      )
    case .fr:
      return PartSearchConfiguration(
        resultsTitle: "Résultats",
        noResultsMessage: "Aucun résultat",
        searchPlaceholder: "Rechercher RIPAM",
        rulesSectionTitle: "Règles",
        ruleDetailTitle: "Règle",
        articleDetailTitle: "Article",
        matchLabel: { $0 > 1 ? "occurrences" : "occurrence" }
      )
    }
  }
  
  private var configuration: PartSearchConfiguration {
    Self.configuration(for: language)
  }
  
  private var ruleParts: [PartModel] {
    switch language {
    case .en:
      return appService.colregs?.colregs ?? []
    case .fr:
      return appService.ripam?.ripam ?? []
    }
  }
  
  private var annexParts: [PartModel] {
    switch language {
    case .en:
      return appService.annexesEn?.colregs ?? []
    case .fr:
      return appService.annexesFr?.ripam ?? []
    }
  }
  
  private var trimmedQuery: String? {
    let trimmed = searchService.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
  
  var body: some View {
    @Bindable var binding = searchService
    NavigationStack {
      partListView
        .navigationTitle(language == .en ? "Colregs" : "RIPAM")
    }
    .searchable(text: $binding.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text(configuration.searchPlaceholder))
    .onAppear(perform: syncService)
    .onChange(of: ruleParts.map(\.id)) { _ in syncService() }
    .onChange(of: annexParts.map(\.id)) { _ in syncService() }
  }
}

private extension ColregsView {
  func syncService() {
    searchService.update(configuration: configuration,
                         ruleParts: ruleParts,
                         annexParts: annexParts)
  }
  
  @ViewBuilder
  var partListView: some View {
    List {
      if let query = trimmedQuery {
        PartSearchResultsSection(configuration: configuration,
                                 query: query,
                                 results: searchService.results)
      } else {
        if !ruleParts.isEmpty {
          Section(configuration.rulesSectionTitle) {
            ForEach(ruleParts) { part in
              NavigationLink(part.title) {
                ruleListView(part: part)
              }
            }
          }
        }
        
        if !annexParts.isEmpty {
          Section("Annexes") {
            ForEach(annexParts) { annex in
              NavigationLink(annex.title) {
                annexListView(part: annex)
              }
            }
          }
        }
      }
    }
  }
  
  func ruleListView(part: PartModel) -> some View {
    List {
      ForEach(part.sections) { section in
        if section.title.isEmpty {
          Section {
            ForEach(section.rules) { rule in
              ruleCellView(rule)
            }
          }
        } else {
          Section("Section \(section.id)") {
            Text(section.title.uppercased())
              .font(.caption)
              .bold()
              .listRowBackground(
                colorScheme == .dark ? Color.secondary.opacity(0.25) : Color.white.opacity(0.8)
              )
            ForEach(section.rules) { rule in
              ruleCellView(rule)
            }
          }
        }
      }
    }
    .navigationTitle(part.title)
    .navigationBarTitleDisplayMode(.inline)
  }
  
  func ruleCellView(_ rule: RuleModel) -> some View {
    NavigationLink {
      RuleView(rule: rule, title: configuration.ruleDetailTitle)
    } label: {
      HStack(alignment: .center) {
        Image(systemName: "\(rule.id).square.fill")
          .foregroundColor(Color.accentColor)
          .font(.title)
        Text("\(rule.title)")
      }
    }
  }
  
  func annexListView(part: PartModel) -> some View {
    List {
      ForEach(part.sections) { section in
        if section.title.isEmpty {
          Section {
            ForEach(section.rules) { rule in
              annexCellView(rule)
            }
          }
        } else {
          Section {
            ForEach(section.rules) { rule in
              annexCellView(rule)
            }
          } header: {
            Text(section.title)
              .textCase(nil)
              .foregroundColor(.primary)
              .font(.title3)
              .bold()
          }
        }
      }
    }
    .navigationTitle(part.title)
    .navigationBarTitleDisplayMode(.inline)
  }
  
  func annexCellView(_ rule: RuleModel) -> some View {
    NavigationLink {
      RuleView(rule: rule, title: configuration.articleDetailTitle)
    } label: {
      HStack(alignment: .top) {
        Image(systemName: "\(rule.id).square.fill")
          .foregroundColor(Color.accentColor)
          .font(.title)
        Text("\(rule.title)")
          .padding(.top, 4)
      }
    }
  }
}

#Preview {
  ColregsView(language: .en)
    .environment(AppService())
}
