//
//  RipamView.swift
//  iColregs
//
//  Created by Christophe Guégan on 20/06/2024.
//

import SwiftUI

struct RipamView: View {
    
    @EnvironmentObject var appVM: AppViewModel    
    @Environment(\.colorScheme) var cs

    
    var body: some View {
        NavigationStack {
            partListView
                .navigationTitle("RIPAM")
        }
        
    }
}

extension RipamView {
    
    /// Parts list View
    /// –––––––––––
    
    @ViewBuilder
    var partListView: some View {
        List {
            if let ripam = appVM.ripam?.ripam {
                Section("Règles") {
                    ForEach(ripam) { part in
                        NavigationLink(part.title) {
                            ruleListView(part: part)
                        }
                    }
                }
            }
            
            if let annexes = appVM.annexesFr?.ripam {
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
    
    /// Rule List view
    /// –––––––––––

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
                                    Color.white.opacity(0.8))
                        
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
            RuleView(rule: rule, title: "Règle")
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
    /// –––––––––––
    
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
    RipamView()
        .environmentObject(AppViewModel())
}
