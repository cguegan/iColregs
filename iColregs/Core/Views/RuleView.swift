//
//  RuleView.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import SwiftUI

struct RuleView: View {
  
  let rule: RuleModel
  let title: String
  let highlightTerm: String?
  
  init(rule: RuleModel, title: String, highlightTerm: String? = nil) {
    self.rule = rule
    self.title = title
    self.highlightTerm = highlightTerm?.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        
        ForEach(rule.content) { content in
          if let image = content.image {
            Image(image)
              .resizable()
              .scaledToFit()
              .clipShape(RoundedRectangle(cornerRadius: 10))
              .shadow(color: .gray.opacity(0.2), radius: 10)
              .padding(.horizontal)
              .padding(.bottom)
          } else {
            HStack(alignment: .top) {
              Text(content.levels)
              highlightedText(content.text, query: trimmedHighlight)
            }
            .padding(.vertical, content.indent.contains("_") ? 1 : 8)
          }
        }
      }
      .padding(.top)
      .navigationTitle("\(title) \(rule.id): \(rule.title)")
      .navigationBarTitleDisplayMode(.inline)
      .padding(.horizontal)
    }
  }
  
  private var trimmedHighlight: String {
    highlightTerm ?? ""
  }
}


// MARK: - Previews
// ————————————————

#Preview {
  let ruleModel = RuleModel(
    id: "5",
    title: "Action to avoid collision",
    content: [
      ContentModel(indent: "_•", text: "Any action taken to avoid collision shall be taken in accordance with the Rules of this Part and shall, if the circumstances of the case admit, be positive, made in ample time and with due regard to the observance of good seamanship.", image: ""),
      ContentModel(indent: "a", text: "Any alteration of course and/or speed to avoid collision shall, if the circumstances of the case admit, be large enough to be readily apparent to another vessel observing visually or by radar; a succession of small alterations of course and/or speed should be avoided.", image: "octave"),
      ContentModel(indent: "_i", text: "A vessel the passage of which is not to be impeded remains fully obliged to comply with the Rules of this Part when the two vessels are approaching one another so as to involve risk of collision.", image: "")
      
    ]
  )
  return NavigationStack {
    RuleView(rule: ruleModel, title: "Rule")
  }
}
