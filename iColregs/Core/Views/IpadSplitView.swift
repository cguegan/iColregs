//
//  IpadSplitView.swift
//  iColregs
//
//  Created by Christophe Guégan on 15/10/2025.
//

import SwiftUI

struct IpadSplitView: View {
  
  @Environment(AppService.self) private var appService
  @State private var language: Language = .en
  @State private var expandedParts: Set<String> = []
  @State private var expandedSections: [String: Set<String>] = [:]
  @AppStorage("IpadSplitView.expandedParts.en") private var storedExpandedPartsEN: String = "[]"
  @AppStorage("IpadSplitView.expandedParts.fr") private var storedExpandedPartsFR: String = "[]"
  @AppStorage("IpadSplitView.expandedSections.en") private var storedExpandedSectionsEN: String = "{}"
  @AppStorage("IpadSplitView.expandedSections.fr") private var storedExpandedSectionsFR: String = "{}"
  
  /// Main Body View
  ///
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
    }
  }
}

extension IpadSplitView {
  
  // MARK: - Sidebar Content Builders
  // ————————————————————————————————
  
  @ViewBuilder
  private var sidebarList: some View {
    List {
      switch language {
      case .en:
        englishColregsList
      case .fr:
        frenchRipamList
      }
    }
    .listStyle(.sidebar)
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
        partList(for: rules, ruleLabel: "Règle")
      }
      
      if !annexes.isEmpty {
        sidebarSeparator(title: "Annexes")
        partList(for: annexes, ruleLabel: "Article")
      }
    }
  }
  
}

// MARK: - Helpers
private extension IpadSplitView {
  
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
  
  /// Part List View
  ///
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
  
  /// Sidebar Separator View
  ///
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
  ///
  @ViewBuilder
  func ruleRow(rule: RuleModel, detailTitle: String) -> some View {
    NavigationLink {
      RuleView(rule: rule, title: detailTitle )
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
  
  func updatePartExpansion(partID: String, isExpanded: Bool) {
    if isExpanded {
      expandedParts.insert(partID)
    } else {
      expandedParts.remove(partID)
      expandedSections[partID] = nil
    }
    persistCurrentExpansionState()
  }
  
  func updateSectionExpansion(partID: String,
                              sectionID: String,
                              isExpanded: Bool) {
    var partSet = expandedSections[partID] ?? []
    if isExpanded {
      partSet.insert(sectionID)
    } else {
      partSet.remove(sectionID)
    }
    expandedSections[partID] = partSet.isEmpty ? nil : partSet
    persistCurrentExpansionState()
  }
  
  func persistCurrentExpansionState() {
    saveExpansionState(for: language,
                       parts: expandedParts,
                       sections: expandedSections)
  }
  
  func loadExpansionState(for language: Language) {
    expandedParts = decodeSet(from: rawParts(for: language))
    expandedSections = decodeSections(from: rawSections(for: language))
  }
  
  func saveExpansionState(for language: Language,
                          parts: Set<String>,
                          sections: [String: Set<String>]) {
    setRawParts(encodeSet(parts), for: language)
    setRawSections(encodeSections(sections), for: language)
  }
  
  func rawParts(for language: Language) -> String {
    switch language {
    case .en:
      return storedExpandedPartsEN
    case .fr:
      return storedExpandedPartsFR
    }
  }
  
  func setRawParts(_ value: String, for language: Language) {
    switch language {
    case .en:
      storedExpandedPartsEN = value
    case .fr:
      storedExpandedPartsFR = value
    }
  }
  
  func rawSections(for language: Language) -> String {
    switch language {
    case .en:
      return storedExpandedSectionsEN
    case .fr:
      return storedExpandedSectionsFR
    }
  }
  
  func setRawSections(_ value: String, for language: Language) {
    switch language {
    case .en:
      storedExpandedSectionsEN = value
    case .fr:
      storedExpandedSectionsFR = value
    }
  }
  
  func encodeSet(_ set: Set<String>) -> String {
    let array = Array(set)
    guard let data = try? JSONEncoder().encode(array),
          let string = String(data: data, encoding: .utf8) else {
      return "[]"
    }
    return string
  }
  
  func decodeSet(from raw: String) -> Set<String> {
    guard let data = raw.data(using: .utf8),
          let array = try? JSONDecoder().decode([String].self, from: data) else {
      return []
    }
    return Set(array)
  }
  
  func encodeSections(_ sections: [String: Set<String>]) -> String {
    let dictionary = sections.mapValues { Array($0) }
    guard let data = try? JSONEncoder().encode(dictionary),
          let string = String(data: data, encoding: .utf8) else {
      return "{}"
    }
    return string
  }
  
  func decodeSections(from raw: String) -> [String: Set<String>] {
    guard let data = raw.data(using: .utf8),
          let dictionary = try? JSONDecoder().decode([String: [String]].self, from: data) else {
      return [:]
    }
    return dictionary.mapValues { Set($0) }
  }
}

#Preview {
  IpadSplitView()
    .environment(AppService())
}
