//
//  ContentView.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import SwiftUI

enum version: Codable {
    case colregs
    case ripam
}

struct ContentView: View {
    
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


// MARK: - Previews
// ————————————————

#Preview {
    ContentView()
}
