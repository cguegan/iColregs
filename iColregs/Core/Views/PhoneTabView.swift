//
//  PhoneTabView.swift
//  iColregs
//
//  Created by Christophe Guégan on 15/10/2025.
//

import SwiftUI

struct PhoneTabView: View {
  
    var body: some View {
      TabView {
          ColregsView(language: .en)
              .tabItem {
                  Label("Colregs", systemImage: "list.bullet.rectangle.portrait.fill")
              }
          
          ColregsView(language: .fr)
              .tabItem {
                  Label("Ripam", systemImage: "list.bullet.rectangle.portrait.fill")
              }
          
          AboutView()
              .tabItem {
                  Label("About", systemImage: "info.circle.fill")
              }
      }
    }
}

#Preview {
  PhoneTabView()
    .environment(AppService())
}
