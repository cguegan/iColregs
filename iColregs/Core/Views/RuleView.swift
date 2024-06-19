//
//  RuleView.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import SwiftUI

struct RuleView: View {
    
    let rule: RuleModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                // Rule Title
                Text(rule.title)
                    .font(.title)
                    .bold()
                    .padding(.bottom)
                
                ForEach(rule.content) { content in
                    HStack(alignment: .top) {
                        Text(content.levels)
                        Text(content.content)
                    }
                    .padding(.bottom)
                    
                }
            }
            .navigationTitle("Rule \(rule.id)")
            .padding(.horizontal)
        }
    }
}


// MARK: - Previews
// ————————————————

#Preview {
    let ruleModel = RuleModel(
        id: "5",
        title: "Action to avoid collision",
        content: [
            ContentModel(indent: "_•", text: "Any action taken to avoid collision shall be taken in accordance with the Rules of this Part and shall, if the circumstances of the case admit, be positive, made in ample time and with due regard to the observance of good seamanship."),
            ContentModel(indent: "a", text: "Any alteration of course and/or speed to avoid collision shall, if the circumstances of the case admit, be large enough to be readily apparent to another vessel observing visually or by radar; a succession of small alterations of course and/or speed should be avoided."),
            ContentModel(indent: "_i", text: "A vessel the passage of which is not to be impeded remains fully obliged to comply with the Rules of this Part when the two vessels are approaching one another so as to involve risk of collision.")
            
        ]
    )
    return NavigationStack {
        RuleView(rule: ruleModel)
    }
}
