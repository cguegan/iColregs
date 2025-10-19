//
//  SearchTabView.swift
//  iColregs
//
//  Created by Christophe Guégan on 26/10/2025.
//

import SwiftUI
import Observation

struct SearchTabView: View {
  @Environment(AppService.self) private var appService
  @State private var language: Language = .en
  @State private var viewModel: SearchViewModel = SearchViewModel(language: .en)
  
  private var configuration: PartSearchConfiguration {
    viewModel.configuration
  }
  
  private var rulePartsFromApp: [PartModel] {
    appService.datasets(for: language).rules
  }
  
  private var annexPartsFromApp: [PartModel] {
    appService.datasets(for: language).annexes
  }
  
  var body: some View {
    @Bindable var binding = viewModel.service
    NavigationStack {
      VStack(spacing: 12) {
        Picker("Language", selection: $language) {
          Text("Colregs").tag(Language.en)
          Text("RIPAM").tag(Language.fr)
        }
        .pickerStyle(.segmented)
        .padding([.top, .horizontal])
        
        List {
          if let query = viewModel.trimmedQuery {
            if viewModel.results.isEmpty {
              Text(configuration.noResultsMessage)
                .foregroundStyle(.secondary)
            } else {
              ForEach(viewModel.results) { result in
                NavigationLink {
                  RuleView(rule: result.rule,
                           title: result.detailTitle,
                           highlightTerm: query)
                } label: {
                  SearchResultRow(result: result,
                                  query: query,
                                  matchLabel: configuration.matchLabel)
                }
              }
            }
          } else {
            Section("Search") {
              Text("Type a term to search \(configuration.rulesSectionTitle.lowercased()) and annexes.")
                .foregroundStyle(.secondary)
            }
          }
        }
      }
      .navigationTitle("Search")
    }
    .searchable(text: $binding.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text(configuration.searchPlaceholder))
    .onAppear(perform: syncViewModel)
    .onChange(of: language) { _, _ in syncViewModel() }
    .onChange(of: rulePartsFromApp.map(\.id)) { _, _ in syncViewModel() }
    .onChange(of: annexPartsFromApp.map(\.id)) { _, _ in syncViewModel() }
  }
  
  private func syncViewModel() {
    viewModel.setLanguage(language,
                          ruleParts: rulePartsFromApp,
                          annexParts: annexPartsFromApp)
  }
}
