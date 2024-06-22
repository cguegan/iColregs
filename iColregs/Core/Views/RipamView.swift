//
//  RipamView.swift
//  iColregs
//
//  Created by Christophe Guégan on 20/06/2024.
//

import SwiftUI

struct RipamView: View {
    
    @EnvironmentObject var appVM: AppViewModel
    
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
            
            if let annexes = appVM.annexes?.annexes {
                Section("Annexes") {
                    ForEach(annexes) { annex in
                        NavigationLink(annex.title) {
                            AnnexView(annex: annex)
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
                            .listRowBackground(Color.white.opacity(0.8))
                        
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
            RuleView(rule: rule)
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
    
    func annexCellView(_ annex: AnnexModel) -> some View {
        NavigationLink {
            //AnnexView(annex: annex)
        } label: {
            HStack(alignment: .center) {
                Image(systemName: "\(annex.id).square.fill")
                    .foregroundColor(Color.accentColor)
                    .font(.title)
                
                Text("\(annex.title)")
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
