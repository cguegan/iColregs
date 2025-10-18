//
//  PhoneTabView.swift
//  iColregs
//
//  Created by Christophe Guégan on 15/10/2025.
//

import SwiftUI

struct PhoneTabView: View {
  
  @StateObject private var appVM = AppViewModel()

    var body: some View {
      TabView {
          ColregsView()
              .tabItem {
                  Label("Colregs", systemImage: "list.bullet.rectangle.portrait.fill")
              }
          
          RipamView()
              .tabItem {
                  Label("Ripam", systemImage: "list.bullet.rectangle.portrait.fill")
              }
          
          AboutView()
              .tabItem {
                  Label("About", systemImage: "info.circle.fill")
              }
      }
      .environmentObject(appVM)
    }
}

#Preview {
  PhoneTabView()
}
