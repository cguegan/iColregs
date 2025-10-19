//
//  PhoneTabView.swift
//  iColregs
//
//  Created by Christophe Guégan on 15/10/2025.
//

import SwiftUI
import Observation

private enum PhoneTab: Hashable {
  case colregsEn
  case colregsFr
  case about
  case search
}

struct PhoneTabView: View {
  @Environment(AppService.self) private var appService
  @State private var selectedTab: PhoneTab = .colregsEn
  @State private var searchText: String = ""
  @State private var searchLanguage: Language = .en
  @State private var searchViewModel: SearchViewModel = SearchViewModel(language: .en)
  
  private var searchConfiguration: PartSearchConfiguration {
    searchViewModel.configuration
  }
  
  var body: some View {
    @Bindable var searchService = searchViewModel.service
    TabView(selection: $selectedTab) {
      Tab(value: PhoneTab.colregsEn) {
        ColregsView(language: .en)
      } label: {
        Label("Colregs", systemImage: "list.bullet.rectangle.portrait.fill")
      }
      
      Tab(value: PhoneTab.colregsFr) {
        ColregsView(language: .fr)
      } label: {
        Label("RIPAM", systemImage: "list.bullet.rectangle.portrait.fill")
      }
      
      Tab(value: PhoneTab.about) {
        AboutView()
      } label: {
        Label("About", systemImage: "info.circle.fill")
      }
      
      Tab(value: PhoneTab.search, role: .search) {
        NavigationStack {
          SearchTabContent(language: $searchLanguage,
                           viewModel: searchViewModel)
            .navigationTitle("Search")
        }
      } label: {
        Label("Search", systemImage: "magnifyingglass")
      }
    }
    .searchable(text: $searchText,
                placement: .toolbar,
                prompt: Text(searchConfiguration.searchPlaceholder))
    .onAppear {
      syncSearchModel(for: searchLanguage)
      searchService.searchText = searchText
    }
    .onChange(of: searchLanguage) { _, newValue in
      syncSearchModel(for: newValue)
    }
    .onChange(of: searchText) { _, newValue in
      if searchService.searchText != newValue {
        searchService.searchText = newValue
      }
    }
    .onChange(of: searchService.searchText) { _, newValue in
      if searchText != newValue {
        searchText = newValue
      }
    }
  }
  
  private func syncSearchModel(for language: Language) {
    let datasets = appService.datasets(for: language)
    searchViewModel.setLanguage(language,
                                ruleParts: datasets.rules,
                                annexParts: datasets.annexes)
  }
}

private struct SearchTabContent: View {
  @Binding var language: Language
  @Bindable var viewModel: SearchViewModel
  
  init(language: Binding<Language>,
       viewModel: SearchViewModel) {
    self._language = language
    self.viewModel = viewModel
  }
  
  private var configuration: PartSearchConfiguration {
    viewModel.configuration
  }
  
  var body: some View {
    List {
      Section {
        Picker("Language", selection: $language) {
          Text("Colregs").tag(Language.en)
          Text("RIPAM").tag(Language.fr)
        }
        .pickerStyle(.segmented)
      }
      
      contentSection
    }
    .listStyle(.insetGrouped)
  }
  
  @ViewBuilder
  private var contentSection: some View {
    if let query = viewModel.trimmedQuery, !query.isEmpty {
      if viewModel.results.isEmpty {
        Section {
          Text(configuration.noResultsMessage)
            .foregroundStyle(.secondary)
        }
      } else {
        Section(configuration.resultsTitle) {
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
      }
    } else {
      Section("Search") {
        Text("Type a term to search \(configuration.rulesSectionTitle.lowercased()) and annexes.")
          .foregroundStyle(.secondary)
      }
    }
  }
}

#Preview {
  PhoneTabView()
    .environment(AppService())
}
