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
  
  // Device type
  private var deviceType: DeviceIdiom { DeviceIdiomProvider.current() }
  
  // Main view body
  var body: some View {
    switch deviceType {
    case .ipad:
      IpadSplitView()
    case .iphone:
      PhoneTabView()
    }
  }
  
}


// MARK: - Previews
// ————————————————

#Preview {
  ContentView()
    .environment(AppService())
}
