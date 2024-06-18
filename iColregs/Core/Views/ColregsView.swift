//
//  ColregsView.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import SwiftUI

struct ColregsView: View {
    
    @EnvironmentObject var appVM: AppViewModel
    
    var body: some View {
        NavigationStack {
            partListView
                .navigationTitle("Colregs")
        }
        
    }
}

// MARK: - Views
// —————————————

extension ColregsView {
    
    /// Parts list View
    @ViewBuilder
    var partListView: some View {
        if let colregs = appVM.colregs?.colregs {
            List {
                ForEach(colregs) { part in
                    NavigationLink(part.title) {
                        ruleListView(part: part)
                    }
                }
            }
        }
    }
    
    // Rule List view
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
                            .listRowBackground(Color.accentColor.opacity(0.1))
                        
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
        HStack(alignment: .center) {
            Image(systemName: "\(rule.id).square.fill")
                .foregroundColor(Color.accentColor)
                .font(.title)
            
            Text("\(rule.title)")
        }
    }
}

#Preview {
    ColregsView()
        .environmentObject(AppViewModel())
}
