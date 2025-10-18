//
//  ColregsView.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import SwiftUI

struct ColregsView: View {
  
  @Environment(AppService.self) private var appService
  @Environment(\.colorScheme) var cs
  @State private var searchText: String = ""
  
  var body: some View {
    NavigationStack {
      partListView
        .navigationTitle("Colregs")
    }
    .searchable(text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text(searchPlaceholder))
  }
}

// MARK: - Views
// —————————————

extension ColregsView {
  
  private var searchQuery: String? {
    let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
  
  private var ruleDetailTitle: String { "Rule" }
  private var articleDetailTitle: String { "Article" }
  private var searchPlaceholder: String { "Search Colregs" }
  private var noResultsMessage: String { "No matches found" }
  
  private var ruleParts: [PartModel] {
    appService.colregs?.colregs ?? []
  }
  
  private var annexParts: [PartModel] {
    appService.annexesEn?.colregs ?? []
  }
  
  private var searchResults: [SearchResult] {
    guard let query = searchQuery else { return [] }
    var results = performSearch(in: ruleParts,
                                query: query,
                                detailTitle: ruleDetailTitle,
                                source: .rule)
    results += performSearch(in: annexParts,
                             query: query,
                             detailTitle: articleDetailTitle,
                             source: .annex)
    return results
  }
  
  @ViewBuilder
  private func searchResultsSection(query: String) -> some View {
    Section("Results") {
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
  
  @ViewBuilder
  private func searchResultRow(result: SearchResult, query: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: "\(result.rule.id).square.fill")
        .font(.title3)
        .foregroundStyle(result.source == .annex ? Color.orange : Color.accentColor)
        .padding(.top, 2)
        .accessibilityHidden(true)
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
  
  private func matchLabel(for count: Int) -> String {
    count == 1 ? "match" : "matches"
  }
  
  /// Parts list View
  /// –––––––––––
  
  @ViewBuilder
  var partListView: some View {
    List {
      if let query = searchQuery {
        searchResultsSection(query: query)
      } else {
        if let colregs = appService.colregs?.colregs {
          Section("Colregs") {
            ForEach(colregs) { part in
              NavigationLink(part.title) {
                ruleListView(part: part)
              }
            }
          }
          
        }
        
        if let annexes = appService.annexesEn?.colregs {
          Section("Annexes") {
            ForEach(annexes) { annex in
              NavigationLink(annex.title) {
                annexListView(part: annex)
              }
            }
          }
        }
      }
    }
  }
  
  // Rule List view
  // –––––––––––———
  
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
            
            // Show title of section
            Text(section.title.uppercased())
              .font(.caption)
              .bold()
              .listRowBackground(
                cs == .dark ?
                Color.secondary.opacity(0.25) :
                  Color.white.opacity(0.8)
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
  
  /// Rule cell View
  /// –––––––––––
  
  func ruleCellView(_ rule: RuleModel) -> some View {
    NavigationLink {
      RuleView(rule: rule, title: "Rule")
    } label: {
      HStack(alignment: .center) {
        Image(systemName: "\(rule.id).square.fill")
          .foregroundColor(Color.accentColor)
          .font(.title)
        
        Text("\(rule.title)")
      }
    }
  }
  
  /// Annex cell View
  /// –––––––––––––
  
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
            // Show title of section
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
  
  /// Annex cell View
  /// –––––––––––––
  
  func annexCellView(_ rule: RuleModel) -> some View {
    NavigationLink {
      RuleView(rule: rule, title: "Article")
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


// MARK: - Previews
// ————————————————

#Preview {
  ColregsView()
    .environment(AppService())
}
