//
//  AboutView.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView(.vertical) {
            
            VStack(alignment: .leading) {
                
                HStack {
                    Spacer()
                    Image("ChristopheGueganSquare")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                    Spacer()
                }
                .padding(.top)
                
                
                Text("Author")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                
                Text(
"""
Christophe Guegan is qualified MCA Master 3000 (Professional captain), ISM DPA and iOS amateur programmer. This app has been made in the purpose of self-teaching SwiftUI© and iOS© programming.
"""
                )
                    .padding(.bottom)
                
                Text("Disclaimer")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                
                Text(
"""
This app is for sole purpose to help students of studying the "COLREGS" or "RIPAM" and should not be taken as a source of truth or as a legal requirement to have onboard the official text on a printed version.

The author has endeavoured to make the information on this app as accurate as possible but cannot take responsibility for any errors or misinterpretation on the application of the rules leading to an accident. The prudent mariner should not rely on this app as a sole source of information.
"""
                )
                    .padding(.bottom)
                
                Text("Copyright")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                
                Text(
"""
The content of this text is in the public domain in the U.S. because it is an edict of a government, local or foreign. See § 313.6(C)(2) of the Compendium II: Copyright Office Practices. Such documents include "legislative enactments, judicial decisions, administrative rulings, public ordinances, or similar types of official legal materials" as well as "any translation prepared by a government employee acting within the course of his or her official duties."

These do not include works of the Organization of American States, United Nations, or any of the UN specialized agencies. See Compendium III § 313.6(C)(2) and 17 U.S.C. 104(b)(5).

The UK version of the COLREGs is provided by the MCA, in the Merchant Shipping (Distress Signals and Prevention of Collisions) Regulations of 1996. They are distributed and accessed in the form of a "Merchant Shipping Notice" (MSN), which is used to convey mandatory information that must be complied with under UK legislation. These MSNs relate to Statutory Instruments and contain the technical detail of such regulations. Material published by the MCA is subject to Crown copyright protection, but the MCA allows it to be reproduced free of charge in any format or medium for research or private study, provided it is reproduced accurately and not used in a misleading context.

Pour la version française, seule la version publiée au Journal Officiel de la république française fait foi. Les données de Légifrance sont mises à disposition pour une réutilisation gratuite comme disposé par l'Arrêté du 24 juin 2014 relatif à la gratuité de la réutilisation des bases de données juridiques de la direction de l'information légale et administrative.
"""
                )
                
                Image("LogoSquare")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                Text("This application is made available to users, free of charge, generously sponsored by:")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack {
                    Spacer()
                    Link("Yachting Concept Monaco", destination: URL(string: "https://www.yachtingconceptmonaco.com")!)
                        .bold()
                        .foregroundStyle(Color.accentColor)
                    Spacer()
                }
                    
            }
            .padding()
        }
    }

}

#Preview {
    AboutView()
}
