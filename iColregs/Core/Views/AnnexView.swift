//
//  AnnexView.swift
//  iColregs
//
//  Created by Christophe Guégan on 19/06/2024.
//

import SwiftUI

struct AnnexView: View {
    
    let annex: AnnexModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                // Rule Title
                Text(annex.subtitle)
                    .bold()
                    .padding(.bottom)
                
                ForEach(annex.content) { content in
                    HStack(alignment: .top) {
                        Text(content.levels)
                        Text(content.content)
                    }
                    .padding(.bottom)
                    
                }
            }
            .navigationTitle("\(annex.title)")
            .padding(.horizontal)
        }
    }
}


// MARK: - Previews
// ————————————————

#Preview {
    let annexModel = AnnexModel(
        id: "1",
        title: "Annex I",
        subtitle: "Positioning and technical details of lights and shapes",
        content: [
            ContentModel(
                indent: "1.",
                text: "Definition"
            ),
            ContentModel(
                indent: "",
                text: "The term **'height above the hull'** means height above the uppermost continuousdeck. This height shall be measured from the position vertically beneath the location of the light."
            ),
            ContentModel(
                indent: "2.",
                text: "Vertical positioning and spacing of lights"
            ),
            ContentModel(
                indent: "_a",
                text: "On a power-driven vessel of 20 metres of more in length the masthead lights shall be placed as follows:"
            ),
        ]
    )
    return AnnexView(annex: annexModel)
}
