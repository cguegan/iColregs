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

enum device: Codable {
  case iphone
  case ipad
}

struct ContentView: View {
  
  // Device idiom helpers
  private var isPhone: Bool {
    UIDevice.current.userInterfaceIdiom == .phone
  }
  
  private var isPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
  }

  private var deviceType: device {
    if isPhone {
      return .iphone
    } else {
      return .ipad
    }
  }
  
  @StateObject private var appVM = AppViewModel()
  
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
}
