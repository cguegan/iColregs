//
//  ColregsView.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import SwiftUI
import Observation

struct ColregsView: View {
  
  /// Instance Properties
  let language: Language
  
  /// Environment Properties
  @Environment(AppService.self) private var appService
  @Environment(\.colorScheme) private var colorScheme
  
  /// State Properties
  @State private var viewModel: SearchViewModel
  
  /// Initializer
  init(language: Language = .en) {
    self.language = language
    _viewModel = State(initialValue: SearchViewModel(language: language))
  }
  
  /// Computed Properties
  private var configuration: PartSearchConfiguration {
    viewModel.configuration
  }
  private var rulePartsFromApp: [PartModel] {
    appService.datasets(for: language).rules
  }
  private var annexPartsFromApp: [PartModel] {
    appService.datasets(for: language).annexes
  }
  
  /// Main Body View
  var body: some View {
    
    @Bindable var binding = viewModel.service
    
    NavigationStack {
      partListView
        .navigationTitle(language == .en ? "Colregs" : "RIPAM")
    }
    .searchable( text: $binding.searchText,
                 placement: .navigationBarDrawer(displayMode: .always),
                 prompt: Text(configuration.searchPlaceholder) )
    .onAppear(perform: syncViewModel)
    .onChange(of: rulePartsFromApp.map(\.id)) { _, _ in syncViewModel() }
    .onChange(of: annexPartsFromApp.map(\.id)) { _, _ in syncViewModel() }
  }
}


// MARK: - Subviews
// ————————————————

private extension ColregsView {
  
  /// Part List View
  /// - Returns:  a view displaying the list of parts or search results.
  ///
  @ViewBuilder
  var partListView: some View {
    List {
      if let query = viewModel.trimmedQuery {
        PartSearchResultsSection(configuration: configuration,
                                 query: query,
                                 results: viewModel.results)
      } else {
        if !viewModel.ruleParts.isEmpty {
          Section(configuration.rulesSectionTitle) {
            ForEach(viewModel.ruleParts) { part in
              NavigationLink(part.title) {
                ruleListView(part: part)
              }
            }
          }
        }
        
        if !viewModel.annexParts.isEmpty {
          Section("Annexes") {
            ForEach(viewModel.annexParts) { annex in
              NavigationLink(annex.title) {
                annexListView(part: annex)
              }
            }
          }
        }
      }
    }
  }
  
  /// Rule List View
  /// - Parameter part: PartModel
  /// - Returns: a view displaying the list of rules in a part.
  ///
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
  
  /// Rule Cell View
  /// - Parameter rule: RuleModel
  /// - Returns: a view displaying a navigation link to a rule detail view.
  ///
  func ruleCellView(_ rule: RuleModel) -> some View {
    NavigationLink {
      RuleView(rule: rule,
               title: configuration.ruleDetailTitle)
    } label: {
      HStack(alignment: .center) {
        Image(systemName: "\(rule.id).square.fill")
          .foregroundColor(Color.accentColor)
          .font(.title)
        Text("\(rule.title)")
      }
    }
  }
  
  /// Annex List View
  /// - Parameter part: PartModel
  /// - Returns: a view displaying the list of annex rules in a part.
  ///
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
  
  /// Annex Cell View
  /// - Parameter rule: RuleModel
  /// - Returns: a view displaying a navigation link to an annex article detail view.
  ///
  func annexCellView(_ rule: RuleModel) -> some View {
    NavigationLink {
      RuleView(rule: rule,
               title: configuration.articleDetailTitle)
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


// MARK: - Private Methods
// ———————————————————————

private extension ColregsView {
  
  /// Sync ViewModel Data
  func syncViewModel() {
    viewModel.setLanguage( language,
                           ruleParts: rulePartsFromApp,
                           annexParts: annexPartsFromApp )
  }
  
}


// MARK: - Previews
// ————————————————

#Preview {
  ColregsView(language: .en)
    .environment(AppService())
}
